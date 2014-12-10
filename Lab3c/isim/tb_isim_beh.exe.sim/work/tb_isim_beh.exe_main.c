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

#include "xsi.h"

struct XSI_INFO xsi_info;

char *IEEE_P_2592010699;
char *STD_STANDARD;
char *IEEE_P_3620187407;
char *IEEE_P_3499444699;
char *IEEE_P_0774719531;


int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    ieee_p_2592010699_init();
    ieee_p_3499444699_init();
    ieee_p_3620187407_init();
    work_a_1991350011_0317204477_init();
    ieee_p_0774719531_init();
    work_a_3081869000_2153311146_init();
    work_a_0989405052_1460233721_init();
    work_a_3161288146_1460233721_init();
    work_a_1781829327_1460233721_init();
    work_a_0502681268_1460233721_init();
    work_a_0109614461_1460233721_init();
    work_a_3396455867_2633534126_init();
    work_a_3003023437_2153311146_init();
    work_a_3409232292_3888899109_init();
    work_a_3061054719_2153311146_init();
    work_a_0114832023_2793452782_init();
    work_a_0272744515_3212880686_init();
    work_a_2096391741_1132359711_init();
    work_a_1111616105_3839485643_init();
    work_a_3136842634_3212880686_init();
    work_a_1430113433_2232266757_init();
    work_a_1335952598_3783779014_init();
    work_a_3671711236_2372691052_init();


    xsi_register_tops("work_a_3671711236_2372691052");

    IEEE_P_2592010699 = xsi_get_engine_memory("ieee_p_2592010699");
    xsi_register_ieee_std_logic_1164(IEEE_P_2592010699);
    STD_STANDARD = xsi_get_engine_memory("std_standard");
    IEEE_P_3620187407 = xsi_get_engine_memory("ieee_p_3620187407");
    IEEE_P_3499444699 = xsi_get_engine_memory("ieee_p_3499444699");
    IEEE_P_0774719531 = xsi_get_engine_memory("ieee_p_0774719531");

    return xsi_run_simulation(argc, argv);

}
