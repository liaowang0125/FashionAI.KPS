cimport cython
import numpy as np
cimport numpy as np

ctypedef np.float_t DTYPE_t

def putGaussianMaps(np.ndarray[DTYPE_t, ndim = 2] entry, DTYPE_t rows,
                    DTYPE_t cols, DTYPE_t center_x, DTYPE_t center_y,  DTYPE_t stride,
                    int grid_x, int grid_y, DTYPE_t sigma):
    cdef DTYPE_t start = stride / 2.0 - 0.5
    cdef DTYPE_t x, y, d2

    for g_y in range(grid_y):
        for g_x in range(grid_x):
            x = start + g_x * stride
            y = start + g_y * stride
            d2 = (x - center_x) * (x - center_x) + (y - center_y) * (y - center_y)
            exponent = d2 / 2.0 / sigma / sigma
            if (exponent > 4.6052):
                continue
            entry[g_y, g_x] += np.exp(-exponent)
            if (entry[g_y, g_x] > 1):
                entry[g_y, g_x] = 1
    return entry


def putVecMaps(np.ndarray[DTYPE_t, ndim = 2] entryX, np.ndarray[DTYPE_t, ndim = 2]  entryY,
               DTYPE_t center1_x, DTYPE_t center1_y, DTYPE_t center2_x, DTYPE_t center2_y,
               DTYPE_t stride, DTYPE_t grid_x, DTYPE_t grid_y, DTYPE_t thres):

    cdef DTYPE_t centerA_x = center1_x / stride
    cdef DTYPE_t centerA_y = center1_y / stride

    cdef DTYPE_t centerB_x = center2_x / stride
    cdef DTYPE_t centerB_y = center2_y / stride

    cdef DTYPE_t vec_x = centerB_x - centerA_x
    cdef DTYPE_t vec_y = centerB_y - centerA_y

    cdef int min_x = max(int(round(min(centerA_x, centerB_x)) - thres), 0)
    cdef int max_x = min(int(round(max(centerA_x, centerB_x))) + thres, grid_x)
    cdef int min_y = max(int(round(min(centerA_y, centerB_y) - thres)), 0)
    cdef int max_y = min(int(round(max(centerA_y, centerB_y) + thres)), grid_y)

    cdef DTYPE_t norm = np.sqrt(vec_x * vec_x + vec_y * vec_y)
    if norm == 0:
        return

    vec_x /= norm
    vec_y /= norm

    cdef DTYPE_t p_x, p_y
    cdef DTYPE_t dist

    for g_y in range(min_y, max_y):
        for g_x in range(min_x, max_x):
            p_x = g_x - centerA_x
            p_y = g_y - centerA_y
            dist = np.absolute(p_x * vec_y - p_y * vec_x)

            if (dist <= thres):
                entryX[g_y, g_x] = vec_x
                entryY[g_y, g_x] = vec_y