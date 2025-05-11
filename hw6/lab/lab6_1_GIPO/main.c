#include <msp430f6638.h>

void update_leds(int count)  
{
  if (count > 5)
  {
    count = 5;
  }
  switch (count)
  {
  case 0:
    P4OUT &= ~0x00e0; 
    P5OUT &= ~BIT7;
    P8OUT &= ~BIT0;
    break;
  case 1:
    P4OUT |= BIT5; 
    P5OUT &= ~BIT7;
    P8OUT &= ~BIT0;
    break;
  case 2:
    P4OUT |= 0x0060; 
    P5OUT &= ~BIT7;
    P8OUT &= ~BIT0;
    break;
  case 3:
    P4OUT |= 0x00e0; 
    P5OUT &= ~BIT7;
    P8OUT &= ~BIT0;
    break;
  case 4:
    P4OUT |= 0x00e0;
    P5OUT |= BIT7;
    P8OUT &= ~BIT0;
    break;
  case 5:
    P4OUT |= 0x00e0;
    P5OUT |= BIT7;
    P8OUT |= BIT0;
    break;
  }
}

void main(void) 
{
  WDTCTL = WDTPW + WDTHOLD;   
  
  P4DIR |= 0x00e0;
  P5DIR |= BIT7;
  P8DIR |= BIT0;

  P4OUT |= 0x001f;
  P4REN |= 0x001f;
  int count = 0;
  int flag = 1;
  update_leds(count);
  while (1)
  {
	if (count > 5) {count = 5;}
    if ((! (P4IN & BIT4)) && flag)
    {
      count++;
      update_leds(count);
       __delay_cycles(1000000);
      flag = 0;
    }

    if (P4IN & BIT4)
    {
      flag = 1;
    }

    if (! (P4IN & BIT3))
    {
      count = 0;
      update_leds(count);
      flag = 1;
    }


  }
}
