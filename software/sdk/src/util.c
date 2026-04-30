#include <math.h>
#include "util.h"

unsigned long int timer;

int similarity_check(double a, double b, double threshold)
{
    return (fabs(a - b) > threshold) ? 0 : 1;
}

int similarity_check_32b(float a, float b, float threshold)
{
    return (fabsf(a - b) > threshold) ? 0 : 1;
}
