#include <msp430.h> 
#include <msp430f6638.h>
/*
 * main.c
 */
void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;
  P4DIR |= BIT7;
  P4DIR &= ~BIT0;
  P4REN |= BIT0;
  P4OUT |= BIT0;
  P4IES |= BIT0;
  P4IFG &= ~BIT0;
  P4IE |= BIT0;

  __bis_SR_register(LPM4_bits + GIE);
  __no_operation();
}

#pragma vector=PORT4_VECTOR
__interrupt void Port_4(void)
{
  P4OUT ^= BIT7;
  P4IFG &= ~BIT0;
__delay_cycles(1000000); // assuming the clock is running at 1MHz for a 1 second delay
  P4OUT ^= BIT7;
}