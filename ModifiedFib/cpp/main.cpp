#include <cstdint>

uint32_t sequence[25];

int main()
{
    sequence[0] = static_cast<uint32_t>(0);
    sequence[1] = static_cast<uint32_t>(1);
    sequence[2] = sequence[1];
    
    for(uint8_t i = 3; i < 25; i++)
    {
        sequence[i] = sequence[i-1] + sequence[i-2] + sequence[i-3];
    }
  
    return 0;
}
