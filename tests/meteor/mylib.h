// Custom C library for Meteor test
#ifndef MYLIB_H
#define MYLIB_H

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

EXPORT int add(int a, int b);
EXPORT int multiply(int a, int b);
EXPORT double average(double a, double b);

#endif
