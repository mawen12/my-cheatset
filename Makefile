ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

generate:
	docker run --rm  -it --volume $$PWD:/tmp:z --name cheatset jonasbn/cheatset:latest generate $(ARGS)

clean:
	rm -r $(ARGS)

cleanall:
	rm -r *.docset