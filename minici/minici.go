package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"sync"
)

var exitf = os.Exit
var server *http.Server
var runner *CmdRunner

func main() {
	conf := "/etc/minici/minici.json"
	if len(os.Args) > 1 {
		conf = os.Args[1]
	}
	minci := &MiniCiConfig{Cmds: map[string]*CmdConfig{}}
	err := ReadJSON(conf, minci)
	if err != nil {
		fmt.Println(err)
		exitf(1)
		return
	}
	if minci.Parallel < 1 {
		minci.Parallel = 5
	}
	SetLogLevel(minci.Log)
	runner = NewCmdRunner()
	runner.Cmds = minci.Cmds
	runner.Parallel = minci.Parallel
	runner.Username = minci.Username
	runner.Password = minci.Password
	http.HandleFunc("/start", runner.StartH)
	http.HandleFunc("/running", runner.RunningH)
	if len(minci.WWW) > 0 {
		http.Handle("/", http.FileServer(http.Dir(minci.WWW)))
	}
	runner.Start()
	InfoLog("CmdRunner listen web server on %v", minci.Addr)
	server = &http.Server{Addr: minci.Addr, Handler: nil}
	err = server.ListenAndServe()
	WarnLog("main is stopped by %v", err)
}

//MiniCiConfig is pojo to mini ci configure
type MiniCiConfig struct {
	Addr     string                `json:"addr"`
	Parallel int                   `json:"parallel"`
	Cmds     map[string]*CmdConfig `json:"cmds"`
	WWW      string                `json:"www"`
	Username string                `json:"username"`
	Password string                `json:"password"`
	Log      int                   `json:"log"`
}

//CmdConfig is pojo to command configure
type CmdConfig struct {
	Path string   `json:"path"`
	Args []string `json:"args"`
	Env  []string `json:"env"`
	Dir  string   `json:"dir"`
	Log  string   `json:"log"`
}

func (c *CmdConfig) String() string {
	bys, _ := json.Marshal(c)
	return string(bys)
}

//CmdRunner provoider fetures to start command by name
type CmdRunner struct {
	stopped      bool
	queue        chan []string
	executing    map[string]*exec.Cmd
	executingLck *sync.RWMutex
	running      map[string]int
	pending      map[string][][]string
	runningLck   *sync.RWMutex
	wait         *sync.WaitGroup
	Cmds         map[string]*CmdConfig
	Parallel     int
	Username     string
	Password     string
}

//NewCmdRunner will return new runner by command map
func NewCmdRunner() (runner *CmdRunner) {
	runner = &CmdRunner{
		queue:        make(chan []string, 10000),
		executing:    map[string]*exec.Cmd{},
		executingLck: &sync.RWMutex{},
		running:      map[string]int{},
		pending:      map[string][][]string{},
		runningLck:   &sync.RWMutex{},
		wait:         &sync.WaitGroup{},
		Cmds:         map[string]*CmdConfig{},
		Parallel:     3,
	}
	return
}

//Add will add command to queue
func (c *CmdRunner) Add(args ...string) {
	if len(args) < 1 {
		panic("not command name")
	}
	c.runningLck.Lock()
	if c.running[args[0]] > 0 {
		c.pending[args[0]] = append(c.pending[args[0]], args)
	} else {
		c.running[args[0]] = 1
		c.queue <- args
	}
	c.runningLck.Unlock()
}

//Start will run all parallel runner
func (c *CmdRunner) Start() {
	InfoLog("CmdRunner bootstrap will %v runner", c.Parallel)
	c.wait.Add(c.Parallel)
	for i := 0; i < c.Parallel; i++ {
		go c.runner()
	}
}

//Stop will kill all executing command
func (c *CmdRunner) Stop() {
	if c.stopped {
		return
	}
	c.stopped = true
	close(c.queue)
	c.executingLck.Lock()
	for _, c := range c.executing {
		c.Process.Kill()
	}
	c.executingLck.Unlock()
}

//Wait will wait all runner stop
func (c *CmdRunner) Wait() {
	c.wait.Wait()
}

func (c *CmdRunner) runner() {
	for {
		args := <-c.queue
		if args == nil {
			break
		}
		c.Run(args[0], args[1:]...)
		c.runningLck.Lock()
		if len(c.pending[args[0]]) > 0 {
			c.queue <- c.pending[args[0]][0]
			c.pending[args[0]] = c.pending[args[0]][1:]
		} else {
			delete(c.running, args[0])
		}
		c.runningLck.Unlock()
	}
	c.wait.Done()
}

//Run run command run by name and arguments
func (c *CmdRunner) Run(name string, args ...string) {
	config := c.Cmds[name]
	if config == nil {
		WarnLog("CmdRunner the command is not exits by %v", name)
		return
	}
	InfoLog("CmdRunner start run %v", name)
	cmd := &exec.Cmd{
		Path: config.Path,
		Args: []string{config.Path},
		Env:  config.Env,
		Dir:  config.Dir,
	}
	if filepath.Base(config.Path) == config.Path {
		lp, err := exec.LookPath(config.Path)
		if err != nil {
			WarnLog("CmdRunner look path for %v by %v fail with %v", name, config.Path, err)
			return
		}
		cmd.Path = lp
	}
	cmd.Args = append(cmd.Args, config.Args...)
	cmd.Args = append(cmd.Args, args...)
	if len(config.Log) > 0 {
		os.MkdirAll(filepath.Dir(config.Log), os.ModePerm)
		logFile, err := os.OpenFile(config.Log, os.O_WRONLY|os.O_CREATE|os.O_APPEND, os.ModePerm)
		if err != nil {
			WarnLog("CmdRunner open log file on %v for %v fail with %v", config.Log, name, err)
			return
		}
		cmd.Stdout = logFile
		cmd.Stderr = logFile
	} else {
		cmd.Stdout = ioutil.Discard
		cmd.Stderr = ioutil.Discard
	}
	c.executingLck.Lock()
	c.executing[name] = cmd
	c.executingLck.Unlock()
	err := cmd.Run()
	if err != nil {
		WarnLog("CmdRunner run %v by config:%v,args:%v fail with %v", name, config, JSON(args), err)
	} else {
		InfoLog("CmdRunner run %v done", name)
	}
	if f, ok := cmd.Stderr.(*os.File); ok {
		f.Close()
	}
	c.executingLck.Lock()
	delete(c.executing, name)
	c.executingLck.Unlock()
}

func (c *CmdRunner) auth(w http.ResponseWriter, r *http.Request) (v bool) {
	if len(c.Username) < 1 {
		return true
	}
	username, password, ok := r.BasicAuth()
	if !ok || username != c.Username || password != c.Password {
		w.Header().Set("WWW-Authenticate", `Basic realm="Dark Socket"`)
		w.WriteHeader(401)
		w.Write([]byte("Login Required.\n"))
		return false
	}
	return true
}

//StartH is http handler to start on task
func (c *CmdRunner) StartH(w http.ResponseWriter, r *http.Request) {
	if !c.auth(w, r) {
		return
	}
	var command string
	if r.Method == "POST" {
		body, _ := ioutil.ReadAll(r.Body)
		command = string(body)
	} else {
		command = r.URL.Query().Get("cmd")
	}
	DebugLog("StartH receive command %v from %v", command, r.RemoteAddr)
	if len(command) < 1 {
		w.WriteHeader(402)
		w.Header().Set("Content-Type", "text/plain;charset=utf8")
		fmt.Fprintf(w, "command argument is required")
		return
	}
	args, err := parseCommandLine(command)
	if err != nil {
		w.WriteHeader(402)
		w.Header().Set("Content-Type", "text/plain;charset=utf8")
		fmt.Fprintf(w, "parse command fail with %v", err)
		return
	}
	c.Add(args...)
	w.Header().Set("Content-Type", "text/plain;charset=utf8")
	fmt.Fprintf(w, "ok")
}

//RunningH is http handler to show running task name
func (c *CmdRunner) RunningH(w http.ResponseWriter, r *http.Request) {
	if !c.auth(w, r) {
		return
	}
	w.Header().Set("Content-Type", "text/plain;charset=utf8")
	buf := bytes.NewBuffer(nil)
	c.runningLck.Lock()
	fmt.Fprintf(buf, "===Pending===\n")
	for n, ps := range c.pending {
		fmt.Fprintf(buf, " %v\n", n)
		for _, p := range ps {
			fmt.Fprintf(buf, "   %v\n", JSON(p))
		}
	}
	fmt.Fprintf(buf, "===Running===\n")
	for r := range c.running {
		fmt.Fprintf(buf, " %v\n", r)
	}
	c.runningLck.Unlock()
	buf.WriteTo(w)
}

func parseCommandLine(command string) ([]string, error) {
	var args []string
	state := "start"
	current := ""
	quote := "\""
	escapeNext := true
	for i := 0; i < len(command); i++ {
		c := command[i]

		if state == "quotes" {
			if string(c) != quote {
				current += string(c)
			} else {
				args = append(args, current)
				current = ""
				state = "start"
			}
			continue
		}

		if escapeNext {
			current += string(c)
			escapeNext = false
			continue
		}

		if c == '\\' {
			escapeNext = true
			continue
		}

		if c == '"' || c == '\'' {
			state = "quotes"
			quote = string(c)
			continue
		}

		if state == "arg" {
			if c == ' ' || c == '\t' {
				args = append(args, current)
				current = ""
				state = "start"
			} else {
				current += string(c)
			}
			continue
		}

		if c != ' ' && c != '\t' {
			state = "arg"
			current += string(c)
		}
	}

	if state == "quotes" {
		return []string{}, fmt.Errorf("Unclosed quote in command line: %s", command)
	}

	if current != "" {
		args = append(args, current)
	}

	return args, nil
}
