#include <stdio.h>
#include <stdlib.h>

void foo3()
{
}

void foo2()
{
  int i;
  for(i=0 ; i < 10; i++)
       foo3();
}

void foo1()
{
  int i;
  for(i = 0; i< 1000; i++)
     foo3();
}

int main(void)
{
  int i;
  for( i =0; i< 1000000000; i++) {
      foo1();
      foo2();
  }
}
