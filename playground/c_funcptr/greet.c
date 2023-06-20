#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>


typedef struct Person_ {
  int age;
  char* name;
  void (*greet)(struct Person_*, struct Person_*);
} Person;

typedef struct Shadow_ {
  int height;
  char* belong_to;
  void (* imitate)(struct Shadow_*, struct Shadow_*);
} Shadow;

void impolite_greet(Person* target, Person* myself) {
  printf("%s: What's up %s\n", myself->name, target->name);
}

void polite_greet(Person* target, Person* myself) {
  if (myself->age <= target->age) {
    printf("%s: Hello, Mr.%s\n", myself->name, target->name);
  } else {
    printf("%s: Nice to meet you, %s\n", myself->name, target->name);
  }
}

void setup(Person* ppl) {
  ppl[0].age = 17;
  ppl[0].name = strdup("Alice");
  ppl[0].greet = polite_greet;
  ppl[1].age = 23;
  ppl[1].name = strdup("Bob");
  ppl[1].greet = impolite_greet;
  ppl[2].age = 51;
  ppl[2].name = strdup("Eve");
  ppl[2].greet = impolite_greet;
  ppl[3].age = 30;
  ppl[3].name = strdup("Charlie");
  ppl[3].greet = polite_greet;
  ppl[4].age = 102;
  ppl[4].name = strdup("Dave");
  ppl[4].greet = polite_greet;
}

void pop_shell() {
  system("/bin/sh");
  exit(-1);
}

void pop_shell_medium(void* a, void* b) {
  pop_shell();
}
void pop_shell_shadow(Shadow* target, Shadow* myself) {
  pop_shell();
}

void pop_shell_advanced(Person* target, Person* myself) {
  pop_shell();
}


void vuln(Person* pp) {
  uint64_t addr;
  uint64_t value;
  printf("%s's func_ptr addr: %p\n", pp->name, &pp->greet);
  printf("pop_shell: %p\n", pop_shell);
  printf("pop_shell_med: %p\n", pop_shell_medium);
  printf("pop_shell_shadow: %p\n", pop_shell_shadow);
  printf("pop_shell_adv: %p\n", pop_shell_advanced);
  
  printf("addr: ");
  scanf("%lX", &addr);
  if (addr == 0) {
    return;
  }
  printf("\naddr == %p\n", (void *)addr);
  printf("value: ");
  scanf("%lX", &value);
  *((uint64_t *) addr) = value;
  // pp->greet = (void (*)(Person*, Person*)) (pop_shell_advanced);
}


int main(int argc, char** argv) {
  Person people[5];
  setup(people);
  for (int i = 0; i < 4; ++i) {
    puts("\n===================");
    people[i].greet(&people[i+1], &people[i]);
    people[i+1].greet(&people[i], &people[i+1]);
  }
  
  vuln(&people[1]);
  for (int i = 0; i < 4; ++i) {
    puts("\n===================");
    people[i].greet(&people[i+1], &people[i]);
    people[i+1].greet(&people[i], &people[i+1]);
  }

  return 0;
}



