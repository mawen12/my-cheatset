package main

import (
	"flag"
	"fmt"
)

var (
	src  string
	dest string
	mode string
)

func init() {
	flag.StringVar(&src, "src", "", "src file")
	flag.StringVar(&dest, "dest", "", "dest file")
	flag.StringVar(&mode, "mode", "compress", "compress or decompress")
	flag.Parse()
}

func main() {
	if src == "" {
		panic("please provide src file path")
	}
	if mode != "compress" && mode != "decompress" {
		panic("please provide valid mode")
	}
	Handle(mode, src, dest)
	fmt.Println(mode + " success")
}
