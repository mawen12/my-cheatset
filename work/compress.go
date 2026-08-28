package main

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"fmt"
	"io"
	"os"
)

func Handle(mode, src, dest string) error {
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}

	var content string
	if mode == "compress" {
		content, err = Compress(data)
	} else if mode == "decompress" {
		content, err = Decompress(data)
	}

	if dest != "" {
		if err := os.WriteFile(dest, []byte(content), 0644); err != nil {
			return err
		}
	} else {
		fmt.Println(content)
	}
	return nil
}

// Compress 将字节数组压缩为base64字符串
func Compress(data []byte) (string, error) {
	var buf bytes.Buffer
	gw := gzip.NewWriter(&buf)

	if _, err := gw.Write(data); err != nil {
		gw.Close()
		return "", err
	}
	if err := gw.Close(); err != nil {
		return "", err
	}

	return base64.StdEncoding.EncodeToString(buf.Bytes()), nil
}

// Decompress 将base64字符串解压为字节数组
func Decompress(data []byte) (string, error) {
	compressed, err := base64.StdEncoding.DecodeString(string(data))
	if err != nil {
		return "", err
	}

	gr, err := gzip.NewReader(bytes.NewReader(compressed))
	if err != nil {
		return "", err
	}
	defer gr.Close()

	content, err := io.ReadAll(gr)
	if err != nil {
		return "", err
	}
	return string(content), err
}
