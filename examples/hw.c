#include <libfoobar.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	struct foobar *foobar;
	int err;

	printf("Let there be foo x %d! Bar said, with a hint of char'm: %s\n",
	       argc, argv[0]);

	err = foobar_alloc(&foobar);
	if (err) {
		FOOBAR_DEBUG("FAILED: foobar_alloc(); err: %d", err);
		return err;
	}

	err = foobar_init(foobar);
	if (err) {
		FOOBAR_DEBUG("FAILED: foobar_init(); err: %d", err);
		goto exit;
	}

	err = foobar_pr(foobar, FOOBAR_PR_DEF);
	if (err < 0) {
		FOOBAR_DEBUG("FAILED: foobar_pr(); err: %d", err);
	}

exit:
	err = foobar_free(foobar);
	if (err) {
		FOOBAR_DEBUG("FAILED: foobar_free(); err: %d", err);
	}

	return err;
}
