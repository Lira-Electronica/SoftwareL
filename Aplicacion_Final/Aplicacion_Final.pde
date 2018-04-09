/*
Universidad Simón Bolivar
Departamento de Electrónica y Circuitos
Laboratorio de Proyectos II - EC3882
Trimestre Enero-Marzo 2018
Seccion 2
Elaborado por: Maria Gabriela Reyes 12-10509.
               Zadkiel Romero       12-11461.
*/
import processing.serial.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;
Minim minim;
AudioOutput out;                                       //Estructura para emitir sonidos a través de la computadora
Serial Port;                                           //Variable de comunicacion serial

//Arreglos que almacenan tres valores consecutivos de cada sensor analogico
int[] A = new int [3];
int[] B = new int [3];
int[] C = new int [3];
//////////////////////////////////////////////////////////////////////////
boolean found;                                        //Bandera que indica que se encontró la cabecera del protocolo de comunicacion      
IntList valIn;                                        //Lista que guarda todos los datos en orden: 
int estado = 1;                                       // Variable para la maquina de estados que se encarga de adquirir los datos desde el protocolo  de comunicacion 
byte con1, con2, con3, con4, con5, con6, con7, con8;  //Variables que almacenan los bytes del protocolo por separado
int inf_1,inf_2,angle,d_1,d_2,d_3;                    //Datos de los sensores en valores enteros.
int i=0,j=0;                                          //Contadores
int flagN=0,flagS=0,anteriorN=0,anteriorS=0;          //Banderas que habilitan el cambio de frecuencias naturales y sostenidas
//boolean z = false;
//boolean centinela = false;
float vumetro,level;                                  //Variables globales: level almacena la amplitud de la onda, 
                                                      //vumetro amplifica el valor de level para dibujarlo en la interfaz
String nota= "Lira";                                  //Texto inicial en pantalla
PFont font1;                                          //Variable que almacena el tipo de fuente de texto

//INICIALIZACION DEL PROGRAMA 
void setup(){
    size(500,700);                                    //Se define el tamaño de pantalla                        
    println(Serial.list());                           //Se imprime la lista de puertos con los que puede haber comunicaicon serial
    Port = new Serial(this, Serial.list()[0], 115200);//Se inicializa la variable por con los parametros (donde,cual, baudios)
    Port.buffer(9);                                   //Se define el tamaño del buffer
    valIn = new IntList();                            //Se inicializa la lista de almacenamiento de datos
    font1 = loadFont("EdwardianScriptITC-140.vlw");   //Se carga la fuente de texto desde la carpeta "data"
    minim = new Minim(this);                          //Le crea la variable minin para ejecutar sonidos en este dispositivo
    out = minim.getLineOut(Minim.STEREO);             //Se define la salida Stereo
}

// BUCLE DE DIBUJO Y PROCESAMIENTO DE DATOS
void draw(){
  if(valIn.size()>=21){                               //Se define un minimo de datos guardados en la lista para procesarlos
    guardarVal(valIn);                                //Se llama a la funcion que pasa los valores de la lista a las variables 
    println(d_1, d_2, d_3, inf_1, inf_2, angle);      //Se imprimen los valores actuales que se procesan 
    sonar(inf_1,inf_2,angle,d_1,d_2,d_3);             //Se pasan todos los datos a la función sonar que se encarga de procesar todos los datos
    delay(2);                                         //Se esperan 2 ms para no saturar la funcion draw
    
    //Aqui se empieza a dibujar
    background(21,4,56);                              //Fondo de la pantalla en modo RGB
    fill(109,10,250);                                 //Relleno de figura en modo RGB
    noStroke();                                       //No dibuja borde en la figura
    ellipse(250,250,290,290);                         //Se crea una cirncuferencia en el centro de la pantalla con estas dos características 
    fill(255);                                        //Relleno de texto en escala de grises (Blanco)
    text(nota,230,290);                               //Se imprime la cadena de caracteres guardada en "notas"
    textFont(font1,140);                              //Se establece la fuente de texto para la cadena 
    textAlign(CENTER);                                //Se alinea el texto en punto medio
    fill(0);                                          //Relleno de figura en escala de grises (Negro)
    rect(0,500,500,200);                              //Se dibuja el rectangulo que aparece en la parte inferior de la pantalla
    stroke(255);                                      //Borde de figura en escala degrises (Blanco)
    strokeWeight(1);                                  //Se define la cantidad de pixeles para dibujar el ancho del borde de la figura
    for(int i = 0; i < out.bufferSize() - 1; i++)     //Iteración que imprime la forma de onda que suena
    {
      float x1 = map(i, 0, out.bufferSize(), 0, width);  //Punto incial
      float x2 = map(i+1, 0, out.bufferSize(), 0, width);//Punto final
      line(x1, 600 + out.left.get(i)*50, x2, 600 + out.left.get(i+1)*50); //Linea entre puntos inicial y final
    }
    noFill();                                         //Figura sin relleno
    stroke(0);                                        //Borde en escala de grises (Negro)
    strokeWeight(80);                                 //Se define el ancho del borde
    ellipse(250,250,400,400);                         //Se dibuja una circunferencia con las caracteristacias recientes
    stroke(255);                                      // Borde en escala de grises (Blanco)
    strokeWeight(5);                                  //Ancho del borde 
    ellipse(250,250,300,300);                         //Circunferencia en con las características recientes
  
/////////////////////////////////////////////// VUMETRO ////////////////////////////////////////////////////////////////////////////
    if(vumetro >= 1 && vumetro <30){ //Para volumenes menores que 30 se dibuja una circunferencia verde sin relleno con Borde ancho      
      noFill();
      stroke(0,255,0);
      strokeWeight(25);
      ellipse(250,250,350,350);
    }
    if(vumetro >= 30 && vumetro <70){//Para volumenes entre 30 y 70 se dibuja una circunferencia verde sin relleno con Borde ancho 
                                     //Junto a una amarilla de radio más grande
      noFill();
      stroke(0,255,0);
      strokeWeight(25);
      ellipse(250,250,350,350);
      noFill();
      stroke(0);
      strokeWeight(15);
      ellipse(250,250,390,390);
      noFill();
      stroke(217,232,21);
      strokeWeight(20);
      ellipse(250,250,400,400);
    }
    if(vumetro >= 70 && vumetro <90){//Para volumenes entre 70 y 90 se dibuja una circunferencia verde sin relleno con Borde ancho 
                                     //Junto a una amarilla de radio más grande y otra Naranja de radio mucho mas grande 
      noFill();
      stroke(0,255,0);
      strokeWeight(25);
      ellipse(250,250,350,350);
      noFill();
      stroke(0);
      strokeWeight(15);
      ellipse(250,250,390,390);
      noFill();
      stroke(217,232,21);
      strokeWeight(20);
      ellipse(250,250,400,400);
      noFill();
      stroke(245,153,5);
      strokeWeight(15);
      ellipse(250,250,440,440);
    }
    if(vumetro >= 90){                //Para volumenes mayores o iguales a 90 se dibuja una circunferencia verde sin relleno con Borde ancho 
                                      //Junto a una amarilla, un naranja y una roja de radio más grande
      noFill();
      stroke(0,255,0);
      strokeWeight(25);
      ellipse(250,250,350,350);
      noFill();
      stroke(0);
      strokeWeight(15);
      ellipse(250,250,390,390);
      noFill();
      stroke(217,232,21);
      strokeWeight(20);
      ellipse(250,250,400,400);
      noFill();
      stroke(245,153,5);
      strokeWeight(15);
      ellipse(250,250,440,440);
      noFill();
      stroke(255,0,0);
      strokeWeight(7);
      ellipse(250,250,466,466);
    }
      valIn.clear();                 //Se limpia la lista para adquirir nuevos datos
    }
}

/////////////////////////////////////// INTERRUPCIONES ////////////////////////////////////////////////
void serialEvent(Serial Port){                                 //Entra la variable que trae los datos a la PC
  byte[] in = new byte[9];                                     //Arreglo del tipo byte para almacenar los datos 
  Port.readBytes(in);                                          //Se guarda el bufer en el arreglo
  
  for(int i=0;i<9;i++){                                        //Se recorre el arreglo hasta encontrar la cabecera
    if(in[i] == -1){                                           
      found = true;                                            //Al encontrar la cabecera, se habilita la bandera de adquisicion de datos
    } 
    if(found){                                                 //Proceamiento de datos activo 
      switch (estado){                                         //Máquina de estados
        case 1:
          estado = 2;                                          //Posicion actual "Cabecera" no se almacena 
          break;
        case 2: 
          con1 = in[i];                                        //Se almacena el segundo byte que contiene los valores de dos sensores digitales y parte de el primer analogico
          valIn.append(decodeDig1(con1));                      //Se almacena en la lista el valor del primer sensor digital
          valIn.append(decodeDig2(con1));                      //Se almacena en la lista el valor del segundo sensor digital
          estado = 3;
          break;
        case 3:
          con2 = in[i];                                        //Se almacena el tercero byte que contiene el resto de los bits del primer sensor analogico
          valIn.append(int(distancia(decode(con1,con2))));     //Se almacena en la lista el valor del primer sensor analogico
          estado = 4;
          break;
        case 4:
          con3 = in[i];                                        //Se almacena el cuarto byte que contiene el valor del tercer sensor digital y parte del segundo sensor analogico
          valIn.append(decodeDig1(con3));                      //Se almacena en la lista el valor del tercer sensor analógico
          estado = 5;
          break;
        case 5:
          con4 = in[i];                                        //Se almacena el quinto byte que contiene el resto de bits que componen al segundo sensor analogico
          valIn.append(int(distancia_2(decode(con3,con4))));   //Se almacena en la lista el valor de segundo sensor analogico 
          estado = 6;
          break;
        case 6:
          con5 = in[i];                                        //Se almacena el sexto byte que contiene parte del valor del eje x del acelerómetro
          estado = 7;
          break;
        case 7:
          con6 = in[i];                                        //Se almacena el septimo byte que contiene el resto de bits del eje X del acelerometro
          estado = 8;
          break;
        case 8:
          con7 = in[i];                                        //Se almacena el octavo byte que contiene parte del valor del eje y del acelerometro 
          estado = 9;
          break;
        case 9:
          con8 = in[i];                                        //Se almacena el noveno byte que contiene el resto del valor en el eje y del acelerometro
          valIn.append((int)angulo_Cal(decode(con5,con6),decode(con7,con8))); //Se almacena en la lista el angulo entre el eje x y y del acelerometro
          estado = 1;
          break;
      }  
      }
    }
}
int decode(byte con1, byte con2){                       //Decodificador de los sensores analogicos
  int aux1, aux2, aux3, aux4, code;
  
  aux1 = con1 & 0x1F;                                   //Mascara para los 4 bits menos significativos de con1  (000XXXXX)
  aux2 = con2 << 1;                                     //Shift hacia la izquierda para con2  (XXXXXXX0) 
  aux3 = aux1 << 8;                                     //Shift hacia izquierda del primer dato (000XXXXX 00000000)
  aux4 = aux2 & 0x00FF;                                 //Mascara para crear dos bytes y mantener el segundo valor (00000000 XXXXXXX0)
  aux4 = aux3 | aux4;                                   //Suma de los dos valores (000XXXXX XXXXXXX0)
  code = aux4 >> 1;                                     //Shift hacia la derecha del resultado (0000XXXX XXXXXXXX)
  
 // code = (int)map(code,0,4096,620,0);                 //Se utiliza para graficar la señal del generador de funciones
  return code;

}
int decodeDig1(byte trama){                             //Decodificador del primer sensor digital
  int sensor=0;                                         //Valor inicial del sensor 
  int aux1,aux2;                                        //Variables auxiliares
  aux1 = trama & 0x40;                                  //Mascara para el bit de interes (0X000000)
  aux2 = aux1>>6;                                       //Shift hacia la derecha (0000000X)
  sensor = (int)aux2;                                   //Se devuelve el valor entero del resultado
  return sensor;
}
int decodeDig2(byte trama){                             //Decodificador del segundo sensor digital
  int sensor=0;                                         //Valor inicial del sensor
  int aux1,aux2;                                        //Variables auxiliares
  aux1 = trama & 0x20;                                  //Mascara para el bit de interes (00X00000)
  aux2 = aux1>>5;                                       //Shift hacia la derecha (0000000X)
  sensor = (int)aux2;                                   //Se devuelve el valor entero del resultado
  return sensor;
}
int ADC_promedio(int[] Valor){                          //Promedio de valores analógicos
  int suma=0,n;                                         //Variables de interes
  n = Valor.length;                                     //Tamaño del arreglo
  for(int i=0;i<n;i++)                                  //Se recorre el arreglo
  {
    suma=suma+Valor[i];                                 //Se suman todos los valores dentro del arreglo
  }  
  return(suma/n);                                       //Se retorna el promedio de todos los valores del arreglo
}

float distancia(int a){                                 //Calcula la distancia del primer sensor analogico 
  float valor;
  valor = 0.615*exp(0.0078*a);                          //Ecuacion que corresponde a la funcion distancia vs valor ADC
  return valor;
}
float distancia_2(int a){                               //Calcula la distancia del segundo sensor analogico 
  float valor;
  valor = 0.6041*exp(0.0078*a);                         //Ecuacion que corresponde a la funcion distancia vs valor ADC
  return valor;
}
float angulo_Cal(int X, int Y){                         //Calcula el angulo con respecto al eje X el acelerometro
  float angulo,aux;                                     //No se usa el eje Y porque no llega informacion suficiente  
    aux=0.1528*X - 91.279;                              //Funcion de aproximacion de angulo por variacion del valor ADC del eje X
    angulo=aux*57.2968;                                 //Conversion de radianes a grados
  return angulo;
}
void guardarVal(IntList val){                           //Guarda los valores de interés en orden
  d_1 = val.remove(0);                                  //Valor del primer sensor digital 
  d_2 = val.remove(0);                                  //Valor del segundo sensor digital
  A[0]=val.remove(0);                                   //Primer valor del sensor infrarrojo de frecuencias naturales
  d_3 = val.remove(0);                                  //Valor del tercer sensor digital
  B[0]=val.remove(0);                                   //Primer valor del sensor infrarrojo de frecuencias sostenidas
  C[0]=val.remove(0);                                   //Primer valor del angulo del acelerometro
  val.remove(0);                                        //Se elimina el siguiente valor del primer sensor digital
  val.remove(0);                                        //Se elimina el siguiente valor del segundo sensor digital
  A[1]=val.remove(0);                                   //Segundo valor del sensor infrarrojo de frecuencias naturales
  val.remove(0);                                        //Se elimina el siguiente valor del tercer sensor digital
  B[1]=val.remove(0);                                   //Segundo valor del sensor infrarrojo de frecuencias sostenidas
  C[1]=val.remove(0);                                   //Segundo valor del angulo del acelerometro
  val.remove(0);                                        //Se elimina el siguiente valor del primer sensor digital
  val.remove(0);                                        //Se elimina el siguiente valor del segundo sensor digital
  A[2]=val.remove(0);                                   //Tercer valor del sensor infrarrojo de frecuencias naturales
  val.remove(0);                                        //Se elimina el siguiente valor del tercer sensor digital
  B[2]=val.remove(0);                                   //Tercer valor del sensor infrarrojo de frecuencias sostenidas
  C[2]=val.remove(0);                                   //Tercer valor del angulo del acelerometro
  
  inf_1 = ADC_promedio(A);                              //Promedio de valores del sensor infrarrojo de frecuencias naturales
  inf_2 = ADC_promedio(B);                              //Promedio de valores del sensor infrarrojo de frecuencias sostenidas
  angle = ADC_promedio(C);                              //Promedio de angulos del acelerometro
}

class MyNote implements AudioSignal                                 //Clase de datos para crear una señal de audio
{
     private float freq;                                            //Frecuencia
     private float alph;                                            //Velocidad de disminucion de volumen
     private TriangleWave triangle;                                 //Forma de onda
     
     MyNote(float pitch, float amplitude, int enableD)              //Onda a sonar con parametro (frecuencia, amplitud, habilitador de distorcion)
     {
         freq = pitch;                                              //Frecuencia de entrada
         level = amplitude;                                         //Variable global que almacena la amplitud de la onda
         triangle = new TriangleWave(freq, level, out.sampleRate());//Forma de onda con parametros(frecuencia, amplitud,rango de sonido)   
       if(enableD==0){                                              //Sucede cuando no hay distorcion
         alph = 0.9;                                                //Velocidad de disminucion de volumen alta 
       }else{                                                       //Sucede cuando hay distorcion
         alph=0.95;                                                 //Velocidad de disminucion de volumen lenta
       }
         out.addSignal(this);                                       //Se activa la funcion sonar de la libreria Minim
     }

  void updateLevel(){                                              //Actualiza la amplitud de la onda
         level = level * alph;                                     //Se multiplica la amplitud actual por el factor de velocidad de disminucion de volumen
         triangle.setAmp(level);                                   //Se modifica la amplitud de la onda
         convert(level);                                           //Se eleva el valor de level para el vumetro
         if (level < 0.01) {
             out.removeSignal(this);                               //Se elimina la señal de audio si su amplitud es muy pequeña
         }
  }
     
  void generate(float [] samp){                                  //Genera la onda constantemente
         triangle.generate(samp);
         updateLevel();
  }
     
  void generate(float [] sampL, float [] sampR){                 //Genera ondas STEREO
        triangle.generate(sampL, sampR);
        updateLevel();
  }

}
void sonar(int dis1,int dis2,int gama,int e_n,int e_s,int e_d){           //Funcion principal del programa
  TriangleWave myTriangle;      
  int pitchN=0,pitchS=0;                                                  //Frecuencias Naturales y Sostenidad iniciales
  float amp;                                                              //Amplitud de onda
  pitchN=selectPitchN(dis1);                                              //Se toma la frecuencia segun la distancia en el sensor de frecuencias naturales
  pitchS=selectPitchS(dis2);                                              //Se toma la frecuencia segun la distancia en el sensor de frecuencias sostenidas
  amp = volumen(gama);                                                    //Se ajusta la amplitud segun la posicion del acelerometro
  MyNote newNote;
  if(e_d==0){                                                             //Sucede cuando no hay distorsion 
    if(e_n==1 && pitchN>0){                                               //Sucede cuando el primer sensor digital esta encendido (se toma la frecuencia de la nota natural)
        newNote = new MyNote(pitchN,amp,e_d);}
    if(e_s==1 && pitchS>0){                                               //Sucede cuando el seguno sensor digital esta encendido (se toma la frecuencia de la nota sostenida)
        newNote = new MyNote(pitchS,amp,e_d);}    
  }else{                                                                  //Sucede cuando hay distorsion 
    if(e_n==1 && pitchN>0){                                               //Sucede cuando el primer sensor digital esta encendido (se toma la frecuencia de la nota natural)                                           
       
  //Se emiten varios tonos alrededor de la frecuencia principal a diferentes amplitudes 
        newNote = new MyNote(pitchN, amp,e_d);                          
        delay(5);
        newNote = new MyNote(pitchN, amp-0.2,e_d);
        delay(10);
        newNote = new MyNote(pitchN, amp+0.1,e_d);
        delay(15);
        newNote = new MyNote(pitchN-100, amp-0.1,e_d);}
    if(e_s==1 && pitchS>0){                                               //Sucede cuando el seguno sensor digital esta encendido (se toma la frecuencia de la nota sostenida)
        newNote = new MyNote(pitchN, amp,e_d);
        delay(5);
        newNote = new MyNote(pitchN, amp-0.2,e_d);
        delay(10);
        newNote = new MyNote(pitchN, amp+0.1,e_d);
        delay(15);
        newNote = new MyNote(pitchN-100, amp-0.1,e_d);}  
  }
}
///// Funcion para detener la emision de los sonidos/////////////
void stop(){
  out.close();
  minim.stop(); 
  super.stop();
}

int selectPitchN(int dis1){                                             //Selector de frecuencias de notas naturales
  int pitch=0;
  if(flagN!=1 && anteriorN==0){                                         //flagN indica cuando suena la nota actual, anteriorN indica si se levanto la baqueta
    if((dis1>=12)&&(dis1<14)){                                          //Rango de distancias a la cual se selecciona la frecuecia pitch 
         pitch = 988; //SI
         flagN = 1;                                                     //Indica si ya se emitió esta nota (Solo suena una sola vez)
         anteriorN=1;                                                   //Indica que la baqueta no se ha levantado
    }
  }                                                                     //Proceso parecido con los siguientes rangos
  if(flagN!=2 && anteriorN==0){
    if((dis1>=15)&&(dis1<17)){
         pitch = 880; //LA
         flagN = 2;
         anteriorN=1;
    }
  }
  if(flagN!=3 && anteriorN==0){
    if((dis1>=18)&&(dis1<20)){
         pitch = 784; //SOL
         flagN = 3;
         anteriorN=1;
    }
  }
  if(flagN!=4 && anteriorN==0){
    if((dis1>=21)&&(dis1<23)){
         pitch = 699; //FA
         flagN = 4;
         anteriorN=1;
    }
  }
  if(flagN!=5 && anteriorN==0){
    if((dis1>=24)&&(dis1<25)){
         pitch = 659;//MI
         flagN = 5;
         anteriorN=1;
    }
  }
  if(flagN!=6 && anteriorN==0){
    if((dis1>=26)&&(dis1<28)){
         pitch = 587;//RE
         flagN = 6;
         anteriorN=1;
    }
  }
  if(flagN!=7 && anteriorN==0){
    if((dis1>=29)&&(dis1<30)){
         pitch = 523; //DO
         flagN = 7;
         anteriorN=1;
    } 
  }
  if(flagN!=0){
    if((dis1>=40)||(dis1<=11)){
        pitch= 0;
        flagN=0;                                                            //Indica que no se ha tocado ninguna nota
        anteriorN=0;                                                        //Indica que la baqueta se levanto
    }
  }        
  return pitch;                                                             //Se retorna la frecuencia  seleccionada 
}

////// SELECTOR DE FRECUENCIAS SOSTENIDAS////////////
//Proceso similar al selector de frecuencias de notas naturales
int selectPitchS(int dis2){
  int pitch = 0;

  if(flagS!=1 && anteriorS==0){
    if((dis2>=13)&&(dis2<15)){
         pitch = 932; //la#
         flagS = 1;
         anteriorS=1;
    }
  }
  if(flagS!=2 && anteriorS==0){
    if((dis2>=16)&&(dis2<18)){
         pitch = 831; //sol#
         flagS = 2;
         anteriorS=1;
    }
  }
  if(flagS!=3 && anteriorS==0){
    if((dis2>=19)&&(dis2<21)){
         pitch = 740; //fa#
         flagS = 3;
         anteriorS=1;
    }
  }
  if(flagS!=4 && anteriorS==0){
    if((dis2>=22)&&(dis2<23)){
         pitch = 622; //re#
         flagS = 4;
         anteriorS=1;
    }
  }
  if(flagS!=5 && anteriorS==0){
    if((dis2>=24)&&(dis2<26)){
         pitch = 554;//do#
         flagS = 5;
         anteriorS=1;
    }
  }
  if(flagS!=0){
    if((dis2>=26)||(dis2<12)){
        pitch= 0;
        flagS=0;
        anteriorS=0;
    }
  }
  return pitch;
}
/////// SELECTOR DE VOLUMEN SEGUN POSICION DEL ACELEROMETRO ///////
float volumen(int angulo){ //Similar al selector de frecuencias con rango en grados 
  float amplitud=0;
  if(angulo<10 && angulo>=0){
    amplitud=0;
  }
  if(angulo<20 && angulo>=10){
    amplitud=0.1;
  }
  if(angulo<30 && angulo>=20){
    amplitud=0.2;
  }
  if(angulo<40 && angulo>=30){
     amplitud=0.3;
  }
  if(angulo<50 && angulo>=40){
     amplitud=0.4;
  }
  if(angulo<60 && angulo>=50){
     amplitud=0.5;
  }
  if(angulo<70 && angulo>=60){
     amplitud=0.6;
  }
  if(angulo<80 && angulo>=70){
     amplitud=0.7;
  }
  if(angulo<90 && angulo>=80){
     amplitud=0.8;
  }
  if(angulo>=90){
     amplitud=0.9;
  }
return amplitud;
}
void convert(float x){       ////Modifica el valor de la amplitud para dibujar el vumetro
  vumetro = x*100;           ///Se guarda en en la variable global "vumetro" valores de volumen entre 0 y 90.
}
