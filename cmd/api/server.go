package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func (app *application) serve() error {
	srv := &http.Server{
		Addr:        fmt.Sprintf(":%d", app.config.port),
		Handler:     app.routes(),
		IdleTimeout: time.Minute,

		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	// Create a shutdownError channel. We will use this to receive any errors returned
	// by the graceful Shutdown() function.
	shutdownError := make(chan error)

	go func() {
		quit := make(chan os.Signal, 1)

		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

		s := <-quit

		app.logger.PrintInfo("Shutting down the server", map[string]string{
			"signal": s.String(),
		})

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

		defer cancel()

		shutdownError <- srv.Shutdown(ctx)
	}()

	err := srv.ListenAndServe()
	if !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	err = <-shutdownError
	if err != nil {
		return err
	}

	app.logger.PrintInfo("Stopped server", map[string]string{
		"addr": srv.Addr,
	})
	return srv.ListenAndServe()
}
