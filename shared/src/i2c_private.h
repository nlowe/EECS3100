#pragma once
#define NVIC_IP_I2C1_EV     0xE000E41F
#define NVIC_ISER_I2C1_EV   0xE000E100

#define NVIC_IP_I2C1_ER     0xE000E420
#define NVIC_ISER_I2C1_ER   0xE000E104

#define FLAG_MASK           0x00FFFFFF

#define I2C_EVENT_MASTER_MODE_SELECT                0x00030001
#define I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED  0x00070082
#define I2C_EVENT_MASTER_BYTE_TRANSMITTED           0x00070084
#define I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED     0x00030002
#define I2C_EVENT_MASTER_BYTE_RECEIVED              0x00030040

#define I2C_EVENT_SLAVE_ACK_FAILURE                 0x00000400