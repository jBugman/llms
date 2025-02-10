package ollama

import (
	"bytes"
	"encoding/json"
	"net/http"
	"time"

	"github.com/samber/lo"
	"github.com/samber/oops"
)

const baseURL = "http://localhost:11434"

type ModelName string

func Tags() ([]ModelName, error) {
	uri := baseURL + "/api/tags"

	hr, err := http.NewRequest(http.MethodGet, uri, nil)
	if err != nil {
		return nil, oops.Wrapf(err, "failed to create request")
	}

	client := http.Client{
		Timeout: 2 * time.Second,
	}

	resp, err := client.Do(hr)
	if err != nil {
		return nil, oops.Wrapf(err, "failed to send request")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, oops.
			With("status", resp.StatusCode).
			Wrapf(err, "request failure")
	}

	type model struct {
		Name ModelName `json:"name"`
	}
	type response struct {
		Models []model `json:"models"`
	}

	var res response
	if err := json.NewDecoder(resp.Body).Decode(&res); err != nil {
		return nil, oops.Wrapf(err, "failed to decode json response")
	}

	tags := lo.Map(res.Models, func(m model, _ int) ModelName {
		return m.Name
	})

	return tags, nil
}

func Generate(prompt string, model ModelName) (string, error) {
	uri := baseURL + "/api/generate"

	type request struct {
		Model ModelName `json:"model"`

		Prompt string `json:"prompt"`

		Stream bool `json:"stream"`
	}
	req := request{
		Model: model,

		Prompt: prompt,
	}
	reqBody, err := json.Marshal(req)
	if err != nil {
		return "", oops.Wrapf(err, "failed to marshal request body")
	}

	hr, err := http.NewRequest(http.MethodGet, uri, bytes.NewReader(reqBody))
	if err != nil {
		return "", oops.Wrapf(err, "failed to create request")
	}

	client := http.Client{
		Timeout: 5 * time.Minute,
	}

	resp, err := client.Do(hr)
	if err != nil {
		return "", oops.Wrapf(err, "failed to send request")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", oops.
			With("status", resp.StatusCode).
			Wrapf(err, "request failure")
	}

	type response struct {
		Response string `json:"response"`
	}

	var res response
	if err := json.NewDecoder(resp.Body).Decode(&res); err != nil {
		return "", oops.Wrapf(err, "failed to decode json response")
	}

	return res.Response, nil
}
