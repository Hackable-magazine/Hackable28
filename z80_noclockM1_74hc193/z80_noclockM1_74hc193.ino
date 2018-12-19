#define RSTDELAY  100

#define B_RESET     7
#define B_WAIT      2
#define B_CPU       8
#define B_PL        6

volatile int gotwait=0;

// réinitialisatio,
void doReset() {
  digitalWrite(B_RESET, LOW);
  delay(RSTDELAY);
  digitalWrite(B_RESET, HIGH);
}

// routine d'interruption
void waitISR() {
    gotwait=1;
}

void stepmode(bool act) {
  if(act)
    digitalWrite(B_PL, HIGH);
  else
    digitalWrite(B_PL, LOW);
}

void dostep() {
  // /WAIT bas ?
  if(gotwait) {
    // réinitialisation
    gotwait=0;
    // "réveil" du Z80
    digitalWrite(B_CPU, LOW); digitalWrite(B_CPU, HIGH);
  }  
}

void setup() {
  // configuration des E/S
  // RESET en sortie
  pinMode(B_RESET, OUTPUT);
  // /WAIT en entrée
  pinMode(B_WAIT, INPUT_PULLUP);
  // UP du 74HCT193 état haut et en sortie
  digitalWrite(B_CPU, HIGH);
  pinMode(B_CPU, OUTPUT);
  // LOAD du 74HCT193 état bas et en sortie
  digitalWrite(B_PL, LOW);
  pinMode(B_PL, OUTPUT);

  // activation du mode signle step
  stepmode(true);

  // Reset Z80 et 74HCT193
  doReset();

  // Appel routine sur changement d'état de la broche /WAIT
  attachInterrupt(digitalPinToInterrupt(B_WAIT), waitISR, FALLING);
}

void loop() {
  // un instruction
  dostep();
  // pause
  delay(1);
}
