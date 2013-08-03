package zephyros_go

import (
	"encoding/json"
	"reflect"
)

type api float64
var API api = 0



func (self api) Bind(key string, mods []string, fn func()) {
	wrapFn := func(bytes []byte) { fn() }
	send(float64(self), wrapFn, true, "bind", key, mods)
}

func (self api) ChooseFrom(list []string, title string, linesTall int, charsWide int, fn func(i int)) {
	wrapFn := func(bytes []byte) {
		var obj *float64
		json.Unmarshal(bytes, &obj)
		if obj == nil {
			fn(-1)
		} else {
			fn(int(*obj))
		}
	}
	send(float64(self), wrapFn, true, "choose_from", list, title, linesTall, charsWide)
}

func (self api) Listen(event string, fn interface{}) {
	fnValue := reflect.ValueOf(fn)
	fnType := fnValue.Type()

	numIn := fnType.NumIn()

	wrapFn := func(bytes []byte) {
		if numIn == 0 {
			fnValue.Call(nil)
		} else {
			inType := fnType.In(0)

			var obj float64
			json.Unmarshal(bytes, &obj)

			objValue := reflect.ValueOf(obj)
			convertedObj := objValue.Convert(inType)

			fnValue.Call([]reflect.Value{convertedObj})
		}
	}
	send(float64(self), wrapFn, true, "listen", event)
}

func (self api) Alert(msg string, dur int) {
	send(float64(self), nil, false, "alert", msg, dur)
}

func (self api) Log(msg string) {
	send(float64(self), nil, false, "log", msg)
}

func (self api) RelaunchConfig() {
	send(float64(self), nil, false, "relaunch_config")
}

func (self api) ClipboardContents() string {
	var buf string
	bytes := send(float64(self), nil, false, "clipboard_contents")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) FocusedWindow() Window {
	var buf Window
	bytes := send(float64(self), nil, false, "focused_window")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) VisibleWindows() []Window {
	var buf []Window
	bytes := send(float64(self), nil, false, "visible_windows")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) AllWindows() []Window {
	var buf []Window
	bytes := send(float64(self), nil, false, "all_windows")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) MainScreen() Screen {
	var buf Screen
	bytes := send(float64(self), nil, false, "main_screen")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) AllScreens() []Screen {
	var buf []Screen
	bytes := send(float64(self), nil, false, "all_screens")
	json.Unmarshal(bytes, &buf)
	return buf
}

func (self api) RunningApps() []App {
	var buf []App
	bytes := send(float64(self), nil, false, "running_apps")
	json.Unmarshal(bytes, &buf)
	return buf
}
