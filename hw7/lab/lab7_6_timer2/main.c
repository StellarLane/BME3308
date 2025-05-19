#include <msp430.h>
#include <msp430f6638.h> // Or your specific MSP430 device header

// Global variables
volatile unsigned int led_active_count = 0; // Number of LEDs to blink (0-5)
volatile unsigned char led_toggle_state = 0; // 0: LEDs are conceptually OFF for this 1s interval, 1: LEDs are ON

// LED definitions
#define LED1_PORT P4OUT
#define LED1_PIN  BIT5 // P4.5

#define LED2_PORT P4OUT
#define LED2_PIN  BIT6 // P4.6

#define LED3_PORT P4OUT
#define LED3_PIN  BIT7 // P4.7

#define LED4_PORT P5OUT
#define LED4_PIN  BIT7 // P5.7

#define LED5_PORT P8OUT
#define LED5_PIN  BIT0 // P8.0

// Button definitions
#define BUTTON_S3_PORT_IN  P4IN
#define BUTTON_S3_PORT_IFG P4IFG
#define BUTTON_S3_PIN  BIT4 // P4.4

#define BUTTON_S4_PORT_IN  P4IN
#define BUTTON_S4_PORT_IFG P4IFG
#define BUTTON_S4_PIN  BIT3 // P4.3

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer

    // Configure LEDs
    P4DIR |= LED1_PIN | LED2_PIN | LED3_PIN; // P4.5, P4.6, P4.7 as output
    P5DIR |= LED4_PIN;                     // P5.7 as output
    P8DIR |= LED5_PIN;                     // P8.0 as output

    // Initially all LEDs off
    LED1_PORT &= ~LED1_PIN;
    LED2_PORT &= ~LED2_PIN;
    LED3_PORT &= ~LED3_PIN;
    LED4_PORT &= ~LED4_PIN;
    LED5_PORT &= ~LED5_PIN;

    // Configure Buttons S3 (P4.4) and S4 (P4.3)
    P4DIR &= ~(BUTTON_S3_PIN | BUTTON_S4_PIN);    // Set P4.4 and P4.3 as input
    P4REN |= (BUTTON_S3_PIN | BUTTON_S4_PIN);     // Enable pull-up/pull-down resistors
    P4OUT |= (BUTTON_S3_PIN | BUTTON_S4_PIN);     // Select pull-up resistors
    P4IES |= (BUTTON_S3_PIN | BUTTON_S4_PIN);     // Interrupt on falling edge
    P4IFG &= ~(BUTTON_S3_PIN | BUTTON_S4_PIN);    // Clear any pending interrupt flags
    P4IE |= (BUTTON_S3_PIN | BUTTON_S4_PIN);      // Enable interrupt for P4.4 and P4.3

    // Configure Timer_A0 for 1-second interrupt (assuming ACLK = 32768 Hz)
    TA0CTL = TASSEL__ACLK | MC__UP | TACLR; // ACLK, Up mode, Clear TAR
    TA0CCR0 = 32767;            // Count for 1 second period ((32767 + 1) / 32768Hz = 1s)
    TA0CCTL0 = CCIE;            // Enable CCR0 interrupt

    __bis_SR_register(LPM0_bits | GIE); // Enter LPM0 with global interrupts enabled

    return 0; // Should not reach here
}

// Timer_A0 CCR0 Interrupt Service Routine
#pragma vector=TIMER0_A0_VECTOR
__interrupt void TIMER0_A0_ISR (void) {
    if (led_toggle_state == 0) { // LEDs were conceptually OFF, turn them ON
        if (led_active_count >= 1) LED1_PORT |= LED1_PIN;
        if (led_active_count >= 2) LED2_PORT |= LED2_PIN;
        if (led_active_count >= 3) LED3_PORT |= LED3_PIN;
        if (led_active_count >= 4) LED4_PORT |= LED4_PIN;
        if (led_active_count >= 5) LED5_PORT |= LED5_PIN;
        led_toggle_state = 1; // Next state: LEDs are ON
    } else { // LEDs were conceptually ON, turn them OFF
        LED1_PORT &= ~LED1_PIN;
        LED2_PORT &= ~LED2_PIN;
        LED3_PORT &= ~LED3_PIN;
        LED4_PORT &= ~LED4_PIN;
        LED5_PORT &= ~LED5_PIN;
        led_toggle_state = 0; // Next state: LEDs are OFF
    }
}

// Port 4 Interrupt Service Routine (for buttons S3 and S4)
#pragma vector=PORT4_VECTOR
__interrupt void Port_4_ISR (void) {
    if (BUTTON_S3_PORT_IFG & BUTTON_S3_PIN) { // Button S3 (P4.4) pressed
        __delay_cycles(20000); // Debounce delay (approx. 20ms if MCLK ~1MHz)
        if (!(BUTTON_S3_PORT_IN & BUTTON_S3_PIN)) { // Check if button is still pressed
            if (led_active_count < 5) {
                led_active_count++;
            }
        }
        BUTTON_S3_PORT_IFG &= ~BUTTON_S3_PIN; // Clear P4.4 interrupt flag
    }

    if (BUTTON_S4_PORT_IFG & BUTTON_S4_PIN) { // Button S4 (P4.3) pressed
        __delay_cycles(20000); // Debounce delay
        if (!(BUTTON_S4_PORT_IN & BUTTON_S4_PIN)) { // Check if button is still pressed
            led_active_count = 0;
            // Turn all LEDs off immediately
            LED1_PORT &= ~LED1_PIN;
            LED2_PORT &= ~LED2_PIN;
            LED3_PORT &= ~LED3_PIN;
            LED4_PORT &= ~LED4_PIN;
            LED5_PORT &= ~LED5_PIN;
            led_toggle_state = 0; // Reset toggle state
        }
        BUTTON_S4_PORT_IFG &= ~BUTTON_S4_PIN; // Clear P4.3 interrupt flag
    }
}