package main

import (
	"bytes"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"
)

var client = &http.Client{}

func httpGet(username, password, u string) (data string, err error) {
	req, err := http.NewRequest("GET", u, nil)
	if len(username) > 0 && len(password) > 0 {
		req.SetBasicAuth(username, password)
	}
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	b, err := ioutil.ReadAll(resp.Body)
	data = string(b)
	resp.Body.Close()
	return
}

type buffer struct {
	*bytes.Buffer
}

func (b *buffer) Close() error {
	return nil
}

func httpPost(username, password, u, body string) (data string, err error) {
	req, err := http.NewRequest("POST", u, nil)
	if len(username) > 0 && len(password) > 0 {
		req.SetBasicAuth(username, password)
	}
	req.Body = &buffer{Buffer: bytes.NewBufferString(body)}
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	b, err := ioutil.ReadAll(resp.Body)
	data = string(b)
	resp.Body.Close()
	return
}

func TestMinici(t *testing.T) {
	wait := make(chan int, 100)
	go func() {
		os.Args = []string{"minici", "./minici.json"}
		main()
		runner.Wait()
		wait <- 1
	}()
	time.Sleep(100 * time.Millisecond)
	data, err := httpGet("test", "123", "http://127.0.0.1:1992/start?cmd="+url.QueryEscape(`echo abc`))
	if err != nil || data != "ok" {
		t.Error(err)
		return
	}
	data, err = httpPost("test", "123", "http://127.0.0.1:1992/start", `echo abc`)
	if err != nil || data != "ok" {
		t.Error(err)
		return
	}
	data, err = httpGet("test", "123", "http://127.0.0.1:1992/start?cmd="+url.QueryEscape(`echo \'abc`))
	if err != nil || data != "ok" {
		t.Error(err)
		return
	}
	data, err = httpGet("test", "123", "http://127.0.0.1:1992/start?cmd="+url.QueryEscape(`echo 'abc xx'`))
	if err != nil || data != "ok" {
		t.Error(err)
		return
	}
	data, err = httpGet("test", "123", "http://127.0.0.1:1992/start?cmd="+url.QueryEscape(`echo 'abc xx`))
	if err != nil || data == "ok" {
		t.Errorf("err:%v,data:%v", err, data)
		return
	}
	data, err = httpGet("test", "123", "http://127.0.0.1:1992/start")
	if err != nil || data == "ok" {
		t.Errorf("err:%v,data:%v", err, data)
		return
	}
	data, err = httpPost("test", "1234", "http://127.0.0.1:1992/start", url.QueryEscape(`echo abc`))
	if err != nil || data == "ok" {
		t.Errorf("err:%v,data:%v", err, data)
		return
	}
	//
	data, err = httpPost("test", "123", "http://127.0.0.1:1992/start", `sleep 10`)
	if err != nil || data != "ok" {
		t.Error(err)
		return
	}
	data, err = httpGet("test", "123", "http://127.0.0.1:1992/running")
	if err != nil || strings.Index(data, "sleep") < 0 {
		t.Error(err)
		return
	}
	time.Sleep(500 * time.Millisecond)
	runner.Stop()
	server.Close()
	<-wait
}
