/*
 * ValorVariablesSubrutinas.c
 * 
 * Copyright 2023 Mauricio <mauricho@Mauri-PC> Mugni Juan Mauricio
 * 
 * 9 de Mayo de 2023
 * 
 * Programa para calcular las variables 1,2,3 para demorar determinado 
 * tiempo en las subrutinas de Asembler, enfocado especialmente para el
 * Pic 16F887 ya que cuenta con 8 bits en sus registros de RAM, donde se 
 * guardarían los valores calculados. Por lo tanto los valores que 
 * pueden tomar las variables son del 0 (mínimo) al 255 (máximo).
 * 
 * Pero en el programa aparece el 256 como máximo ya que sirve para 
 * hacer los calculos analíticos, pero a la hora de ponerlo en Asembler 
 * se debe cambiar por un 0.
 * 
 * Cuando restamos por primera vez 0 con la instrucción de Asembler:
 * DECFSZ f,d pasamos a 0xFF = 255d. Por lo tanto consideramos al 0 como
 * 256.
 *   
 * Nos brinda información acerca de que valor tienen que tomar estas 
 * variables para poder llegar al tiempo deseado.
 * 
 * Recordar: Los valores que pueden tomar son del 0 a 255!!
 * 
 * Puede tener algún error!
 */


#include <stdio.h>

void getDatos(int*,double*,double*);
void calcUnaVar(int*,double);
void calcDosVar(int*,double);
void calcTresVar(int*,double);
double calcPrincipal(double*,double*);

int cicloMaquina = 4; // 1 ciclo reloj = 4 ciclo maquina

int main(int argc, char **argv)
{
	double frecuencia, tiempo;
	int numNops;
	char temp;
	
	printf("* Programa para calcular el valor de las "); 
	printf("variables de las subrutinas de tiempo *\n\n");
	
	do
	{
		getDatos(&numNops,&frecuencia,&tiempo); // Pido los datos al usuario
	
		// Calculo el número de ciclos necesarios
		double numCicloNec = calcPrincipal(&frecuencia,&tiempo);

		// Calculo los valores para una variable
		calcUnaVar(&numNops, numCicloNec); 
		
		// Calculo los valores para dos variables
		calcDosVar(&numNops, numCicloNec);  
		
		// Calculo los valores para tres variables
		calcTresVar(&numNops, numCicloNec);
		
		printf("\n¿Introducir otros valores?S/n ");
		fflush(stdin); // Vaciar el buffer de entrada del teclado
		scanf(" %c", &temp);

	}while(temp == 'S' || temp == 's');
	
	return 0;
}

/*
 * Función que me permite pedir los datos al usuario.
 * @cantNops: La cantidad de Nops que tenga el programa.
 * @frec: Frecuencia del oscilador a utilizar.
 * @timeDeseado: El tiempo que se esta pretendiendo obtener.
 */
void getDatos(int* cantNops,double* frec,double* timeDeseado)
{
	double frec2, timeDeseado2;
	
	printf("\nFrecuencia [MHz]: ");
	scanf("%lf",&frec2);
	
	printf("Tiempo deseado [uS]: ");
	scanf("%lf",&timeDeseado2);
	
	printf("Cantidad de Nops: ");
	scanf("%d",cantNops);

	*frec = frec2*1E6; // Paso de MHz a Hz
	
	*timeDeseado = timeDeseado2*1E-6; // Paso de uS a S
}

/*
 * Función que me calcula los valores para una variable.
 */
void calcUnaVar(int* cantNops,double numCicloNecesario)
{
	int var1,numCicloReales,numCicloFaltante;

	// Número de ciclos máximos
	float numCicloMax = 5+(256*(*cantNops+3));
	
	printf("\n********** Resultado con 1 variable **************\n\n");
	
	//Pregunto si necesito más ciclos de lo que puedo llegar
	if(numCicloMax < numCicloNecesario) 
	{
		printf("\t No se puede hacer!\n\n");
		var1=0; // Es el máximo valor que puede tomar
	}
	else
		var1 = ((int)numCicloNecesario-5) / (*cantNops+3);

	numCicloReales = 5+var1*(*cantNops+3);
	numCicloFaltante = (int) (numCicloNecesario - numCicloReales);
	
	printf("Var1 es: %d\n",var1);
	printf("Los ciclos de maquina son: %d\n",numCicloReales);
	printf("Los ciclos faltantes son: %d\n",numCicloFaltante);
}

/*
 * Función que me calcula los valores para dos variable.
 */
void calcDosVar(int* cantNops,double numCicloNecesario)
{
	int var1,var2,numCicloReales,numCicloFaltante,auxCicloFaltante;
	
	// Número de ciclos máximos
	float numCicloMax = 7+256*(256*(*cantNops+3)+4);
	
	printf("\n********** Resultado con 2 variable **************\n\n");
	
	//Pregunto si necesito más ciclos de lo que puedo llegar
	if(numCicloMax < numCicloNecesario)
	{
		printf("\t No se puede hacer!\n\n");
		var1=0; // Son los máximos valores que pueden tomar
		var2=0;
		numCicloReales = numCicloMax;
		numCicloFaltante = (int) (numCicloNecesario - numCicloReales);
	}
	else
	{	
		/*
		Debo comparar entre 1 y 256 por el cero es el mayor número si es decrementado,
		teniendo un valor de 256 ciclos hasta llgar a 0 y el 1 es el menor, este último 
		repitiendose una sola vez.
		*/
		for(int i=1;i<=256;i++)		//var2
		{
			for(int j=1;j<=256;j++) //var1
			{
				numCicloReales = 7+i*(j*(*cantNops+3)+4);
				auxCicloFaltante = (int)numCicloNecesario - numCicloReales;
				
		//Condición que se hace una vez para comparar con el resto de los resultados
				if(i==1 && j==1) 
					numCicloFaltante = auxCicloFaltante;
				
				if(numCicloFaltante >= auxCicloFaltante && auxCicloFaltante>=0)
				{
					numCicloFaltante = auxCicloFaltante;
					var2=i;
					var1=j;
				}	
			}
		}
		//Corrijo el valor del numCiclo Real, ya que queda con el último
		numCicloReales = 7+var2*(var1*(*cantNops+3)+4);
	}
	//Realizo una corrección del 256 cambiandolo por 0, ya que el 256 no se puede escribir
	if(var1==256)
		var1=0;
	if(var2==256)
		var2=0;
	printf("Var1 es: %d\n",var1);
	printf("Var2 es: %d\n",var2);
	printf("Los ciclos de maquina son: %d\n",numCicloReales);
	printf("Los ciclos faltantes son: %d\n",numCicloFaltante);
}

/*
 * Función que me calcula los valores para tres variable.
 */
void calcTresVar(int* cantNops,double numCicloNecesario)
{
	int var1,var2,var3,numCicloReales,numCicloFaltante,auxCicloFaltante;
	
	// Número de ciclos máximos
	float numCicloMax = 9+256*(4*(1+256)+256*256*(3+*cantNops));
	
	printf("\n********** Resultado con 3 variable **************\n\n");
	
	//Pregunto si necesito más ciclos de lo que puedo llegar
	if(numCicloMax < numCicloNecesario)
	{
		printf("\t No se puede hacer!\n\n");
		var1=0;
		var2=0;
		var3=0; //Son los máximos valores que puede tomar
		numCicloReales = numCicloMax;
		numCicloFaltante = (int)numCicloNecesario - numCicloReales;
	}
	else
	{	
		/*
		Debo comparar entre 1 y 256 por el cero es el mayor número si es decrementado,
		teniendo un valor de 256 ciclos hasta llgar a 0 y el 1 es el menor, este último 
		repitiendose una sola vez.
		*/
		for(int i=1;i<=256;i++)			//var2
		{
			for(int j=1;j<=256;j++) 	//var1
			{
				for(int k=1;k<=256;k++) //var3
				{
					numCicloReales = 9+k*(4*(1+j)+j*i*(*cantNops+3));
					auxCicloFaltante = (int)numCicloNecesario - numCicloReales;
					
			//Condición que se hace una vez para comparar con el resto de los resultados
					if(i==1 && j==1 && k==1) 
						numCicloFaltante = auxCicloFaltante;
					
					if(numCicloFaltante >= auxCicloFaltante && auxCicloFaltante>=0)
					{
						numCicloFaltante = auxCicloFaltante;
						var2=i;
						var1=j;
						var3=k;
					}	
				}
			}
		}
		//Corrijo el valor del numCiclo Real, ya que queda con el último
		numCicloReales = 9+var3*(4*(1+var1)+var1*var2*(*cantNops+3));
	}
	//Realizo una corrección del 256 cambiandolo por 0, ya que el 256 no se puede escribir
	if(var1==256)
		var1=0;
	if(var2==256)
		var2=0;
	if(var3==256)
		var3=0;	
	printf("Var1 es: %d\n",var1);
	printf("Var2 es: %d\n",var2);
	printf("Var3 es: %d\n",var3);
	printf("Los ciclos de maquina son: %d\n",numCicloReales);
	printf("Los ciclos faltantes son: %d\n",numCicloFaltante);
}

/*
 * Función que se encarga de hacer las cuentas principales y así obtener
 * el número de ciclos necesarios de acuerdo a la frecuencia de oscilación 
 * y al tiempo deseado.
 * @fOsc: es la frecuencia de oscilación
 * @tDes: es el tiempo deseado
 * @numCicloNeces: es el la dirección del valor que se retorna
 * Si la pantalla muestra un ciclo de maquina muy pequeño el resultado mostrado sera 0.
 */
double calcPrincipal(double* fOsc,double* tDes)
{
	// Frecuencia de cada Instrucción
	double frecPorInstr = *fOsc/cicloMaquina;
	
	// Tiempo de cada ciclo de máquina
	double tiempPorCicloMaquina = 1 / frecPorInstr; 
	
	printf("\nDuracion de cada ciclo de maquina: %.8lf[S]\n",tiempPorCicloMaquina);
	
	// Número de ciclos que se necesitan para llegar al tiempo pedido
	double numCicloNeces = (*tDes) / tiempPorCicloMaquina;

	return numCicloNeces;
}



