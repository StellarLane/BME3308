#include <msp430.h> 
#include <msp430f6638.h>
/*
 * main.c
 */

void delay_ms(unsigned int ms) {
    unsigned int i, j;
    for(i = 0; i < ms; i++)
        for(j = 0; j < 1000; j++);
}

int main(void) {
    WDTCTL = WDTPW | WDTSSEL__ACLK | WDTIS_4; // 看门狗模式，ACLK，约1s溢出
    P4DIR |= BIT5 | BIT6 | BIT7;    // P4.5、P4.6、P4.7设为输出（接LED）
    P4OUT |= BIT5 | BIT6 | BIT7;    // P4.5, P4.6, P4.7 outputs low (LED on)
    __delay_cycles(500000); // 延时100ms，使用系统时钟
    P4OUT &= ~BIT5; 
    P4OUT &= ~BIT6;
    P4OUT &= ~BIT7;
    while(1) {
        P4OUT ^= BIT5;    // LED闪烁
        // delay_ms(500);    // 延时
        __delay_cycles(50000); // 延时50ms，使用系统时钟
        // 喂狗，防止复位
        WDTCTL = WDTPW | WDTCNTCL | WDTSSEL__ACLK | WDTIS_4;
        // 如果不喂狗，系统会在约1秒后自动复位，LED会重新开始闪烁
    }
}