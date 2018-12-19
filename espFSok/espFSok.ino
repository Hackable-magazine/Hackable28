#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <FS.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS D4  // DS18B20 pin

const char* ssid = "APmonSSID";
const char* password = "mot2passe";
const char* hostString = "nomhote";
const char* otapass = "123456";

unsigned long previousMillis = 0;

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature DS18B20(&oneWire);

void confOTA() {
  // Port 8266 (défaut)
  ArduinoOTA.setPort(8266);

  // Hostname défaut : esp8266-[ChipID]
  ArduinoOTA.setHostname(hostString);

  // mot de passe pour OTA
  //ArduinoOTA.setPassword(otapass);

  ArduinoOTA.onStart([]() {
    Serial.println("/!\\ Maj OTA");
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\n/!\\ MaJ terminee");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progression: %u%%\r", (progress / (total / 100)));
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  ArduinoOTA.begin();
}

void setup() {
  FSInfo fs_info;

  Serial.begin(115200);
  Serial.println("Boot...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Erreur connexion Wifi! Reboot...");
    delay(5000);
    ESP.restart();
  }

  /*
  uint32_t realSize = ESP.getFlashChipRealSize();
  uint32_t ideSize = ESP.getFlashChipSize();
  FlashMode_t ideMode = ESP.getFlashChipMode();

  Serial.printf("Flash real id:   %08X\r\n", ESP.getFlashChipId());
  Serial.printf("Flash real size: %u\r\n", realSize);

  Serial.printf("Flash ide  size: %u\r\n", ideSize);
  Serial.printf("Flash ide speed: %u\r\n", ESP.getFlashChipSpeed());
  Serial.printf("Flash ide mode:  %s\r\n", (ideMode == FM_QIO ? "QIO" : ideMode == FM_QOUT ? "QOUT" : ideMode == FM_DIO ? "DIO" : ideMode == FM_DOUT ? "DOUT" : "UNKNOWN"));

  if(ideSize != realSize) {
      Serial.println("Flash Chip configuration wrong!");
  } else {
      Serial.println("Flash Chip configuration ok.");
  }
  */

  confOTA();

  Serial.print(">>> Nom host: ");
  Serial.println(hostString);
  Serial.print(">>> Adresse IP: ");
  Serial.println(WiFi.localIP());

  if(SPIFFS.begin()) {
    SPIFFS.info(fs_info);

    Serial.print("Total FFS: ");
    Serial.print(fs_info.totalBytes/1024);
    Serial.println(" Ko");

    Serial.print("Libre FFS: ");
    Serial.print((fs_info.totalBytes - fs_info.usedBytes)/1024);
    Serial.println(" Ko");

    Serial.println("\nFichier(s):");
    Dir dir = SPIFFS.openDir("/");
    while (dir.next()) {
      Serial.print(dir.fileName());
      Serial.print("\t\t");
      File f = dir.openFile("r");
      Serial.println(f.size());
      f.close();
    }
  }
}

void loop() {
  unsigned long currentMillis = millis();
  float temp;

  if (currentMillis - previousMillis >= 30000) {
    previousMillis = currentMillis;
    File f = SPIFFS.open("/temp.txt", "a+");
    if (!f) {
      Serial.println("file open failed");
    } else {
      DS18B20.requestTemperatures();
      temp = DS18B20.getTempCByIndex(0);
      //String txttemp = String(temp).c_str();
      f.println(String(temp).c_str());
      Serial.println("----------");
      f.seek(0, SeekSet);
      int compte = 0;
      while (f.available()){
        Serial.println(f.readStringUntil('\n'));
        compte++;
      }
      Serial.print(compte);
      Serial.println(" ----------");
      f.close();
    }
  }
  ArduinoOTA.handle();
}
