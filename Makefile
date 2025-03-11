

lost-signal: lost-signal.tm box.tm raylib.tm player.tm world.tm camera.tm satellite.tm
	tomo -e lost-signal.tm

# Disable built-in makefile rules:
%: %.c
%.o: %.c
%: %.o

clean:
	rm -vf lost-signal *.tm.*

play: lost-signal
	./lost-signal

.PHONY: play, clean
