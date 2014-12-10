/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Sivly.Sivly-PC/Documents/GitHub/MIPS-lab3c/Lab3c/nshifter.vhd";



static void work_a_0502681268_1460233721_p_0(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    int t18;

LAB0:    xsi_set_current_line(46, ng0);
    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(55, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t1 = (t0 + 3472);
    t5 = (t1 + 56U);
    t8 = *((char **)t5);
    t13 = (t8 + 56U);
    t14 = *((char **)t13);
    memcpy(t14, t2, 32U);
    xsi_driver_first_trans_fast_port(t1);

LAB3:    t1 = (t0 + 3392);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(47, ng0);
    t1 = (t0 + 1512U);
    t5 = *((char **)t1);
    t6 = *((unsigned char *)t5);
    t7 = (t6 == (unsigned char)3);
    if (t7 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(51, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t9 = (32 - 1);
    t18 = (t9 - 8);
    t10 = (31 - t18);
    t11 = (t10 * 1U);
    t12 = (0 + t11);
    t1 = (t2 + t12);
    t5 = (t0 + 3472);
    t8 = (t5 + 56U);
    t13 = *((char **)t8);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t1, 24U);
    xsi_driver_first_trans_delta(t5, 0U, 24U, 0LL);
    xsi_set_current_line(52, ng0);
    t1 = xsi_get_transient_memory(8U);
    memset(t1, 0, 8U);
    t2 = t1;
    memset(t2, (unsigned char)2, 8U);
    t5 = (t0 + 3472);
    t8 = (t5 + 56U);
    t13 = *((char **)t8);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t1, 8U);
    xsi_driver_first_trans_delta(t5, 24U, 8U, 0LL);

LAB6:    goto LAB3;

LAB5:    xsi_set_current_line(48, ng0);
    t1 = (t0 + 1032U);
    t8 = *((char **)t1);
    t9 = (32 - 1);
    t10 = (31 - t9);
    t11 = (t10 * 1U);
    t12 = (0 + t11);
    t1 = (t8 + t12);
    t13 = (t0 + 3472);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t1, 24U);
    xsi_driver_first_trans_delta(t13, 8U, 24U, 0LL);
    xsi_set_current_line(49, ng0);
    t1 = xsi_get_transient_memory(8U);
    memset(t1, 0, 8U);
    t2 = t1;
    t5 = (t0 + 1352U);
    t8 = *((char **)t5);
    t3 = *((unsigned char *)t8);
    memset(t2, t3, 8U);
    t5 = (t0 + 3472);
    t13 = (t5 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t1, 8U);
    xsi_driver_first_trans_delta(t5, 0U, 8U, 0LL);
    goto LAB6;

}


extern void work_a_0502681268_1460233721_init()
{
	static char *pe[] = {(void *)work_a_0502681268_1460233721_p_0};
	xsi_register_didat("work_a_0502681268_1460233721", "isim/TOP_isim_beh.exe.sim/work/a_0502681268_1460233721.didat");
	xsi_register_executes(pe);
}
