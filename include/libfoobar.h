/**
 * libfoobar: misc stuff when playing around with C
 *
 * Copyright (C) Simon A. F. Lund <os@safl.dk>
 * SPDX-License-Identifier: Apache-2.0
 *
 * @file libxnvme_util.h
 */
#ifndef __LIBFOOBAR_H
#define __LIBFOOBAR_H
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>
#include <assert.h>

/**
 * Macro wrapping C11 static assert, currently experiencing issues with the
 * asserts on FreeBSD, so trying this...
 */
#ifdef static_assert
#define FOOBAR_STATIC_ASSERT(cond, msg) static_assert(cond, msg);
#else
#define FOOBAR_STATIC_ASSERT(cond, msg)
#endif

/**
 * Macro to suppress warnings on unused arguments, thanks to stackoverflow.
 */
#ifdef __GNUC__
#define FOOBAR_UNUSED(x) UNUSED_ ## x __attribute__((__unused__))
#else
#define FOOBAR_UNUSED(x) UNUSED_ ## x
#endif

#ifdef FOOBAR_DEBUG_ENABLED

#define FOOBAR_DEBUG_FCALL(x) x

#define __FILENAME__ strrchr("/" __FILE__, '/') + 1

#define FOOBAR_DEBUG(...) \
	fprintf(stderr, "# DBG:%s:%s-%d: " FIRST(__VA_ARGS__) "\n" , \
		__FILENAME__, __func__, __LINE__ REST(__VA_ARGS__)); \
	fflush(stderr);

#define FIRST(...) FIRST_HELPER(__VA_ARGS__, throwaway)
#define FIRST_HELPER(first, ...) first

#define REST(...) REST_HELPER(NUM(__VA_ARGS__), __VA_ARGS__)
#define REST_HELPER(qty, ...) REST_HELPER2(qty, __VA_ARGS__)
#define REST_HELPER2(qty, ...) REST_HELPER_##qty(__VA_ARGS__)
#define REST_HELPER_ONE(first)
#define REST_HELPER_TWOORMORE(first, ...) , __VA_ARGS__
#define NUM(...) \
	SELECT_10TH(__VA_ARGS__, TWOORMORE, TWOORMORE, TWOORMORE, TWOORMORE,\
		    TWOORMORE, TWOORMORE, TWOORMORE, TWOORMORE, ONE, throwaway)
#define SELECT_10TH(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, ...) a10

#else
#define FOOBAR_DEBUG(...)
#define FOOBAR_DEBUG_FCALL(x)
#endif

struct foobar {
	int x;
	int y;
};

enum foobar_pr_opts {
	FOOBAR_PR_DEF = 0x1 << 0,
	FOOBAR_PR_YAML = 0x1 << 1,
	FOOBAR_PR_TXT = 0x1 << 2
};

int
foobar_alloc(struct foobar **foobar);

int
foobar_free(struct foobar *foobar);

int
foobar_init(struct foobar *foobar);

int
foobar_fpr(FILE *stream, const struct foobar *foobar, int opts);

int
foobar_pr(const struct foobar *foobar, int opts);

#endif /* __LIBFOOBAR_H */
