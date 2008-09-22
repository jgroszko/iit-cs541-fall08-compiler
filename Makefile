all: out.s driver.c
	gcc -g out.s driver.c