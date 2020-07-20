#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <libfoobar.h>

int
foobar_alloc(struct foobar **foobar)
{
	*foobar = malloc(sizeof(**foobar));

	if (!*foobar) {
		return -errno;
	}

	return 0;
}

int
foobar_free(struct foobar *foobar)
{
	if (!foobar) {
		return -EINVAL;
	}

	free(foobar);

	return 0;
}

int
foobar_init(struct foobar *foobar)
{
	foobar->x = 1;
	foobar->y = 2;

	return 0;
}

int
foobar_fpr(FILE *stream, const struct foobar *foobar, int opts)
{
	int wrtn = 0;

	switch (opts) {
	case FOOBAR_PR_DEF:
	case FOOBAR_PR_YAML:
		break;

	case FOOBAR_PR_TXT:
	default:
		return -1;
	}

	wrtn += fprintf(stream, "foobar:");
	if (!foobar) {
		wrtn += fprintf(stream, " ~\n");
		return wrtn;
	}

	wrtn += fprintf(stream, "{ x: %d, y: %d }\n", foobar->x, foobar->y);

	return wrtn;
}

int
foobar_pr(const struct foobar *foobar, int opts)
{
	return foobar_fpr(stdout, foobar, opts);
}
