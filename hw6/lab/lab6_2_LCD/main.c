/*
 * main.c
 */
#include <msp430f6638.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "dr_lcdseg.h"   //���ö�ʽҺ������ͷ�ļ�

#define XT2_FREQ   4000000

#define MCLK_FREQ 16000000
#define SMCLK_FREQ 4000000



void initClock()
{
  while(BAKCTL & LOCKIO) BAKCTL &= ~(LOCKIO);
  UCSCTL6 &= ~XT1OFF; //����XT1��ѡ���ڲ�ʱ��Դ
  P7SEL |= BIT2 + BIT3; //XT2���Ź���ѡ��
  UCSCTL6 &= ~XT2OFF; //����XT2
  while (SFRIFG1 & OFIFG) //�ȴ�XT1��XT2��DCO�ȶ�
  {
    UCSCTL7 &= ~(DCOFFG+XT1LFOFFG+XT2OFFG);
    SFRIFG1 &= ~OFIFG;
  }
  UCSCTL4 = SELA__XT1CLK + SELS__XT2CLK + SELM__XT2CLK; //����DCO�������ܷ�
  UCSCTL1 = DCORSEL_5; //6000kHz~23.7MHz
  UCSCTL2 = MCLK_FREQ / (XT2_FREQ / 16); //XT2Ƶ�ʽϸߣ���Ƶ����Ϊ��׼�ɻ�ø��ߵľ���
  UCSCTL3 = SELREF__XT2CLK + FLLREFDIV__16; //XT2����16��Ƶ����Ϊ��׼
  while (SFRIFG1 & OFIFG) //�ȴ�XT1��XT2��DCO�ȶ�
  {
    UCSCTL7 &= ~(DCOFFG+XT1LFOFFG+XT2OFFG);
    SFRIFG1 &= ~OFIFG;
  }
  UCSCTL5 = DIVA__1 + DIVS__1 + DIVM__1; //�趨����CLK�ķ�Ƶ
  UCSCTL4 = SELA__XT1CLK + SELS__XT2CLK + SELM__DCOCLK; //�趨����CLK��ʱ��Դ
}

void main(void)
{
	unsigned char num1;
  int i;
  int32_t num2;
  WDTCTL = WDTPW | WDTHOLD; // ֹͣ���Ź�
  initClock();              // ����ϵͳʱ��
  initLcdSeg();             // ��ʼ����ʽҺ��
  const int date[6] = {0, 3, 0, 5, 2, 5};
  while (1) // ���������ѭ��
  {
    for (i = 0; i < 6; i++)
    {
      LCDSEG_SetDigit(i, date[i]);
      LCDSEG_SetSpecSymbol(4);
    }
    __delay_cycles(MCLK_FREQ * 4);
    for (i = 0; i < 6; i++)
    {
      LCDSEG_SetDigit(i, -1);
    }
    for (i = 0; i < 3; i++)
    {
      display_SJTU(i);
      __delay_cycles(MCLK_FREQ * 4);
    }

  }
}


