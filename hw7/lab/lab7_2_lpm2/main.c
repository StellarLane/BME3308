#include <msp430.h>
#include <msp430f6638.h>
int main(void) {
    WDTCTL = WDTPW | WDTHOLD; // 关闭看门狗

    P1DIR |= BIT0;    // P1.0设置为输出
    P1SEL |= BIT0;    // P1.0选择外设功能（输出ACLK）

    // 进入低功耗模式3
    __bis_SR_register(LPM3_bits);

    // 如果要测试LPM4，把上面一行改为LPM4_bits
    // __bis_SR_register(LPM4_bits);
    while (1);
    return 0;
}