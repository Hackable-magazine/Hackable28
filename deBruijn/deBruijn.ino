void setbit(unsigned char* list, unsigned long pos) {
  list[(pos/8)] |= (128 >> (pos % 8));
}

int getbit(unsigned char* list, unsigned long pos) {
  if(list[(pos/8)] & (128 >> (pos % 8)))
    return 1;
  else
    return 0;
}

int getbitsub(unsigned char sub, unsigned long pos) {
  if(sub & (128 >> (pos % 8)))
    return 1;
  else
    return 0;
}

void debruijn(int n) {
  // max n=8
  // longueur suite = 4096 = 512*8 bits
  // nombre de combinaisons = 4096 = 512*8 bits
  unsigned char suite[512] = {0};
  unsigned char liste[512] = {0};

  // on marque n*0=0 comme présent
  setbit(liste, 0);
  
  // on saute les n premiers bits à 0
  for(unsigned long i=n; i<pow(2,n)+n-1; i++) {
    uint32_t sub = 0;
    
    // on compose le début de la sous-suite pour test    
    for(int j=(n-1); j>0; j--) {
      sub |= (getbit(suite, i-j) << j);
    }

    // on regarde que la sous-suite avec un 1 en plus existe déjà
    if(getbit(liste, sub | 1) == 0) {
      // non, on set ce bit dans la suite
      setbit(suite, i);
      // et on marque la sous-suite comme maintenant présente
      setbit(liste, sub | 1);
      continue;
    // sinon, est-ce que la sous-suite existe avec un 0 en plus ?
    } else if(getbit(liste, sub | 0) == 0) {
      // non, on marque la sous-suite comme maintenant présente
      setbit(liste, sub | 0);
    } else {
      // la sous-suite avec un 1 et avec un 0 existent, on arrête
      Serial.println("stop");
      break;
    }
  }

  // affichage de la suite
  for(unsigned long i=0; i<pow(2,n); i++) {
    Serial.print(getbit(suite,i) ? "1" : "0");
  }
  Serial.println("");

  for(unsigned long i=0; i<pow(2,n); i++) {
    Serial.print(getbit(liste,i) ? "1" : "0");
  }
  Serial.println("");
}

void setup() {
  Serial.begin(115200);
  Serial.println("Go go go !");
  debruijn(8);
}

void loop() {
  delay(100);
}
