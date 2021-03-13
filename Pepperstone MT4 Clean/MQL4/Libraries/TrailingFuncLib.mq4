//+------------------------------------------------------------------+
//|                                                  TrailingAll.mq4 |
//|                                                              I_D |
//|             Софт для управления капиталом: http://www.mymmk.com/ |
//+------------------------------------------------------------------+
#property copyright "I_D / Юрий Дзюбан"
#property link      "http://www.mymmk.com/ Софт для управления капиталом"
#property library

static datetime sdtPrevtime = 0;

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО ФРАКТАЛАМ                                            |
//| Функции передаётся тикет позиции, количество баров в фрактале,   |
//| и отступ (пунктов) - расстояние от макс. (мин.) свечи, на        |
//| которое переносится стоплосс (от 0), trlinloss - тралить ли в    |
//| зоне убытков                                                     |
//+------------------------------------------------------------------+
void TrailingByFractals(int ticket,int tmfrm,int frktl_bars,int indent,bool trlinloss)
   {
   int i, z; // counters
   int extr_n; // номер ближайшего экстремума frktl_bars-барного фрактала 
   double temp; // служебная переменная
   int after_x, be4_x; // свечей после и до пика соответственно
   int ok_be4, ok_after; // флаги соответствия условию (1 - неправильно, 0 - правильно)
   int sell_peak_n, buy_peak_n; // номера экстремумов ближайших фракталов на продажу (для поджатия дл.поз.) и покупку соответсвенно   
   
   // проверяем переданные значения
   if ((frktl_bars<=3) || (indent<0) || (ticket==0) || ((tmfrm!=1) && (tmfrm!=5) && (tmfrm!=15) && (tmfrm!=30) && (tmfrm!=60) && (tmfrm!=240) && (tmfrm!=1440) && (tmfrm!=10080) && (tmfrm!=43200)) || (!OrderSelect(ticket,SELECT_BY_TICKET)))
      {
      Print("Трейлинг функцией TrailingByFractals() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   temp = frktl_bars;
      
   if (MathMod(frktl_bars,2)==0)
   extr_n = temp/2;
   else                
   extr_n = MathRound(temp/2);
      
   // баров до и после экстремума фрактала
   after_x = frktl_bars - extr_n;
   if (MathMod(frktl_bars,2)!=0)
   be4_x = frktl_bars - extr_n;
   else
   be4_x = frktl_bars - extr_n - 1;    
   
   // если длинная позиция (OP_BUY), находим ближайший фрактал на продажу (т.е. экстремум "вниз")
   if (OrderType()==OP_BUY)
      {
      // находим последний фрактал на продажу
      for (i=extr_n;i<iBars(Symbol(),tmfrm);i++)
         {
         ok_be4 = 0; ok_after = 0;
         
         for (z=1;z<=be4_x;z++)
            {
            if (iLow(Symbol(),tmfrm,i)>=iLow(Symbol(),tmfrm,i-z)) 
               {
               ok_be4 = 1;
               break;
               }
            }
            
         for (z=1;z<=after_x;z++)
            {
            if (iLow(Symbol(),tmfrm,i)>iLow(Symbol(),tmfrm,i+z)) 
               {
               ok_after = 1;
               break;
               }
            }            
         
         if ((ok_be4==0) && (ok_after==0))                
            {
            sell_peak_n = i; 
            break;
            }
         }
     
      // если тралить в убытке
      if (trlinloss==true)
         {
         // если новый стоплосс лучше имеющегося (в т.ч. если стоплосс == 0, не выставлен)
         // а также если курс не слишком близко, ну и если стоплосс уже не был перемещен на рассматриваемый уровень         
         if ((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      // если тралить только в профите, то
      else
         {
         // если новый стоплосс лучше имеющегося И курса открытия, а также не слишком близко к текущему курсу
         if ((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderOpenPrice()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }
      
   // если короткая позиция (OP_SELL), находим ближайший фрактал на покупку (т.е. экстремум "вверх")
   if (OrderType()==OP_SELL)
      {
      // находим последний фрактал на продажу
      for (i=extr_n;i<iBars(Symbol(),tmfrm);i++)
         {
         ok_be4 = 0; ok_after = 0;
         
         for (z=1;z<=be4_x;z++)
            {
            if (iHigh(Symbol(),tmfrm,i)<=iHigh(Symbol(),tmfrm,i-z)) 
               {
               ok_be4 = 1;
               break;
               }
            }
            
         for (z=1;z<=after_x;z++)
            {
            if (iHigh(Symbol(),tmfrm,i)<iHigh(Symbol(),tmfrm,i+z)) 
               {
               ok_after = 1;
               break;
               }
            }            
         
         if ((ok_be4==0) && (ok_after==0))                
            {
            buy_peak_n = i;
            break;
            }
         }        
      
      // если тралить в убытке
      if (trlinloss==true)
         {
         if (((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0)) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }      
      // если тралить только в профите, то
      else
         {
         // если новый стоплосс лучше имеющегося И курса открытия
         if ((((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0))) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderOpenPrice()) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО ТЕНЯМ N СВЕЧЕЙ                                       |
//| Функции передаётся тикет позиции, количество баров, по теням     |
//| которых необходимо трейлинговать (от 1 и больше) и отступ        |
//| (пунктов) - расстояние от макс. (мин.) свечи, на которое         |
//| переносится стоплосс (от 0), trlinloss - тралить ли в лоссе      | 
//+------------------------------------------------------------------+
void TrailingByShadows(int ticket,int tmfrm,int bars_n, int indent,bool trlinloss)
   {  
   
   int i; // counter
   double new_extremum;
   
   // проверяем переданные значения
   if ((bars_n<1) || (indent<0) || (ticket==0) || ((tmfrm!=1) && (tmfrm!=5) && (tmfrm!=15) && (tmfrm!=30) && (tmfrm!=60) && (tmfrm!=240) && (tmfrm!=1440) && (tmfrm!=10080) && (tmfrm!=43200)) || (!OrderSelect(ticket,SELECT_BY_TICKET)))
      {
      Print("Трейлинг функцией TrailingByShadows() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY), находим минимум bars_n свечей
   if (OrderType()==OP_BUY)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iLow(Symbol(),tmfrm,i);
         else 
         if (new_extremum>iLow(Symbol(),tmfrm,i)) new_extremum = iLow(Symbol(),tmfrm,i);
         }         
      
      // если тралим и в зоне убытков
      if (trlinloss==true)
         {
         // если найденное значение "лучше" текущего стоплосса позиции, переносим 
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum - indent*Point,OrderTakeProfit(),OrderExpiration()))            
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      else
         {
         // если новый стоплосс не только лучше предыдущего, но и курса открытия позиции
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum - indent*Point)>OrderOpenPrice()) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum-indent*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
      
   // если короткая позиция (OP_SELL), находим минимум bars_n свечей
   if (OrderType()==OP_SELL)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iHigh(Symbol(),tmfrm,i);
         else 
         if (new_extremum<iHigh(Symbol(),tmfrm,i)) new_extremum = iHigh(Symbol(),tmfrm,i);
         }         
           
      // если тралим и в зоне убытков
      if (trlinloss==true)
         {
         // если найденное значение "лучше" текущего стоплосса позиции, переносим 
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      else
         {
         // если новый стоплосс не только лучше предыдущего, но и курса открытия позиции
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderOpenPrice()) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }      
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ СТАНДАРТНЫЙ-СТУПЕНЧАСТЫЙ                                |
//| Функции передаётся тикет позиции, расстояние от курса открытия,  |
//| на котором трейлинг запускается (пунктов) и "шаг", с которым он  |
//| переносится (пунктов)                                            |
//| Пример: при +30 стоп на +10, при +40 - стоп на +20 и т.д.        |
//+------------------------------------------------------------------+

void TrailingStairs(int ticket,int trldistance,int trlstep)
   { 
   
   double nextstair; // ближайшее значение курса, при котором будем менять стоплосс

   // проверяем переданные значения
   if ((trldistance<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trlstep<1) || (trldistance<trlstep) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("Трейлинг функцией TrailingStairs() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()))
      nextstair = OrderOpenPrice() + trldistance*Point;
         
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      nextstair = OrderStopLoss() + trldistance*Point;

      // если текущий курс (Bid) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Bid>=nextstair)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()) && (OrderOpenPrice() + trlstep*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)) 
            {
            if (!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + trlstep*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      else
         {
         if (!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss() + trlstep*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()))
      nextstair = OrderOpenPrice() - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
      
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      nextstair = OrderStopLoss() - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
       
      // если текущий курс (Аск) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Ask<=nextstair)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()) && (OrderOpenPrice() - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      else
         {
         if (!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()- (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ СТАНДАРТНЫЙ-ЗАТЯГИВАЮЩИЙСЯ                              |
//| Функции передаётся тикет позиции, исходный трейлинг (пунктов) и  |
//| 2 "уровня" (значения профита, пунктов), при которых трейлинг     |
//| сокращаем, и соответствующие значения трейлинга (пунктов)        |
//| Пример: исходный трейлинг 30 п., при +50 - 20 п., +80 и больше - |
//| на расстоянии в 10 пунктов.                                      |
//+------------------------------------------------------------------+

void TrailingUdavka(int ticket,int trl_dist_1,int level_1,int trl_dist_2,int level_2,int trl_dist_3)
   {  
   
   double newstop = 0; // новый стоплосс
   double trldist; // расстояние трейлинга (в зависимости от "пройденного" может = trl_dist_1, trl_dist_2 или trl_dist_3)

   // проверяем переданные значения
   if ((trl_dist_1<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_2<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_3<MarketInfo(Symbol(),MODE_STOPLEVEL)) || 
   (level_1<=trl_dist_1) || (level_2<=trl_dist_1) || (level_2<=level_1) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("Трейлинг функцией TrailingUdavka() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // если профит <=trl_dist_1, то trldist=trl_dist_1, если профит>trl_dist_1 && профит<=level_1*Point ...
      if ((Bid-OrderOpenPrice())<=level_1*Point) trldist = trl_dist_1;
      if (((Bid-OrderOpenPrice())>level_1*Point) && ((Bid-OrderOpenPrice())<=level_2*Point)) trldist = trl_dist_2;
      if ((Bid-OrderOpenPrice())>level_2*Point) trldist = trl_dist_3; 
            
      // если стоплосс = 0 или меньше курса открытия, то если тек.цена (Bid) больше/равна дистанции курс_открытия+расст.трейлинга
      if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()))
         {
         if (Bid>(OrderOpenPrice() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }

      // иначе: если текущая цена (Bid) больше/равна дистанции текущий_стоплосс+расстояние трейлинга, 
      else
         {
         if (Bid>(OrderStopLoss() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }
      
      // модифицируем стоплосс
      if ((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // если профит <=trl_dist_1, то trldist=trl_dist_1, если профит>trl_dist_1 && профит<=level_1*Point ...
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_1*Point) trldist = trl_dist_1;
      if (((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_1*Point) && ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_2*Point)) trldist = trl_dist_2;
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_2*Point) trldist = trl_dist_3; 
            
      // если стоплосс = 0 или меньше курса открытия, то если тек.цена (Ask) больше/равна дистанции курс_открытия+расст.трейлинга
      if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()))
         {
         if (Ask<(OrderOpenPrice() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask + trldist*Point;
         }

      // иначе: если текущая цена (Bid) больше/равна дистанции текущий_стоплосс+расстояние трейлинга, 
      else
         {
         if (Ask<(OrderStopLoss() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask +  trldist*Point;
         }
            
       // модифицируем стоплосс
      if (newstop>0)
         {
         if (((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice())) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))  
               {
               if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
               Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
               }
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО ВРЕМЕНИ                                              |
//| Функции передаётся тикет позиции, интервал (минут), с которым,   |
//| передвигается стоплосс и шаг трейлинга (на сколько пунктов       |
//| перемещается стоплосс, trlinloss - тралим ли в убытке            |
//| (т.е. с определённым интервалом подтягиваем стоп до курса        |
//| открытия, а потом и в профите, либо только в профите)            |
//+------------------------------------------------------------------+
void TrailingByTime(int ticket,int interval,int trlstep,bool trlinloss)
   {
      
   // проверяем переданные значения
   if ((ticket==0) || (interval<1) || (trlstep<1) || !OrderSelect(ticket,SELECT_BY_TICKET))
      {
      Print("Трейлинг функцией TrailingByTime() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      }
      
   double minpast; // кол-во полных минут от открытия позиции до текущего момента 
   double times2change; // кол-во интервалов interval с момента открытия позиции (т.е. сколько раз должен был быть перемещен стоплосс) 
   double newstop; // новое значение стоплосса (учитывая кол-во переносов, которые должны были иметь место)
   
   // определяем, сколько времени прошло с момента открытия позиции
   minpast = (TimeCurrent() - OrderOpenTime()) / 60;
      
   // сколько раз нужно было передвинуть стоплосс
   times2change = MathFloor(minpast / interval);
         
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // если тралим в убытке, то отступаем от стоплосса (если он не 0, если 0 - от открытия)
      if (trlinloss==true)
         {
         if (OrderStopLoss()==0) newstop = OrderOpenPrice() + times2change*(trlstep*Point);
         else newstop = OrderStopLoss() + times2change*(trlstep*Point); 
         }
      else
      // иначе - от курса открытия позиции
      newstop = OrderOpenPrice() + times2change*(trlstep*Point); 
         
      if (times2change>0)
         {
         if ((newstop>OrderStopLoss()) && (newstop<Bid- MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      // если тралим в убытке, то отступаем от стоплосса (если он не 0, если 0 - от открытия)
      if (trlinloss==true)
         {
         if (OrderStopLoss()==0) newstop = OrderOpenPrice() - times2change*(trlstep*Point) - MarketInfo(Symbol(),MODE_SPREAD)*Point;
         else newstop = OrderStopLoss() - times2change*(trlstep*Point) - MarketInfo(Symbol(),MODE_SPREAD)*Point;
         }
      else
      newstop = OrderOpenPrice() - times2change*(trlstep*Point) - MarketInfo(Symbol(),MODE_SPREAD)*Point;
                
      if (times2change>0)
         {
         if (((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice())) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         else
         if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО ATR (Average True Range, Средний истинный диапазон)  |
//| Функции передаётся тикет позиции, период АТR и коэффициент, на   |
//| который умножается ATR. Т.о. стоплосс "тянется" на расстоянии    |
//| ATR х N от текущего курса; перенос - на новом баре (т.е. от цены |
//| открытия очередного бара)                                        |
//+------------------------------------------------------------------+
void TrailingByATR(int ticket,int atr_timeframe,int atr1_period,int atr1_shift,int atr2_period,int atr2_shift,double coeff,bool trlinloss)
   {
   // проверяем переданные значения   
   if ((ticket==0) || (atr1_period<1) || (atr2_period<1) || (coeff<=0) || (!OrderSelect(ticket,SELECT_BY_TICKET)) || 
   ((atr_timeframe!=1) && (atr_timeframe!=5) && (atr_timeframe!=15) && (atr_timeframe!=30) && (atr_timeframe!=60) && 
   (atr_timeframe!=240) && (atr_timeframe!=1440) && (atr_timeframe!=10080) && (atr_timeframe!=43200)) || (atr1_shift<0) || (atr2_shift<0))
      {
      Print("Трейлинг функцией TrailingByATR() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      }
   
   double curr_atr1; // текущее значение ATR - 1
   double curr_atr2; // текущее значение ATR - 2
   double best_atr; // большее из значений ATR
   double atrXcoeff; // результат умножения большего из ATR на коэффициент
   double newstop; // новый стоплосс
   
   // текущее значение ATR-1, ATR-2
   curr_atr1 = iATR(Symbol(),atr_timeframe,atr1_period,atr1_shift);
   curr_atr2 = iATR(Symbol(),atr_timeframe,atr2_period,atr2_shift);
   
   // большее из значений
   best_atr = MathMax(curr_atr1,curr_atr2);
   
   // после умножения на коэффициент
   atrXcoeff = best_atr * coeff;
              
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // откладываем от текущего курса (новый стоплосс)
      newstop = Bid - atrXcoeff;           
      
      // если trlinloss==true (т.е. следует тралить в зоне лоссов), то
      if (trlinloss==true)      
         {
         // если стоплосс неопределен, то тралим в любом случае
         if ((OrderStopLoss()==0) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         // иначе тралим только если новый стоп лучше старого
         else
            {
            if ((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      else
         {
         // если стоплосс неопределен, то тралим, если стоп лучше открытия
         if ((OrderStopLoss()==0) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         // если стоп не равен 0, то меняем его, если он лучше предыдущего и курса открытия
         else
            {
            if ((newstop>OrderStopLoss()) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      // откладываем от текущего курса (новый стоплосс)
      newstop = Ask + atrXcoeff;
      
      // если trlinloss==true (т.е. следует тралить в зоне лоссов), то
      if (trlinloss==true)      
         {
         // если стоплосс неопределен, то тралим в любом случае
         if ((OrderStopLoss()==0) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         // иначе тралим только если новый стоп лучше старого
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      else
         {
         // если стоплосс неопределен, то тралим, если стоп лучше открытия
         if ((OrderStopLoss()==0) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         // если стоп не равен 0, то меняем его, если он лучше предыдущего и курса открытия
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ RATCHET БАРИШПОЛЬЦА                                     |
//| При достижении профитом уровня 1 стоплосс - в +1, при достижении |
//| профитом уровня 2 профита - стоплосс - на уровень 1, когда       |
//| профит достигает уровня 3 профита, стоплосс - на уровень 2       |
//| (дальше можно трейлить другими методами)                         |
//| при работе в лоссовом участке - тоже 3 уровня, но схема работы   |
//| с ними несколько иная, а именно: если мы опустились ниже уровня, |
//| а потом поднялись выше него (пример для покупки), то стоплосс    |
//| ставим на следующий, более глубокий уровень (например, уровни    |
//| -5, -10 и -25, стоплосс -40; если опустились ниже -10, а потом   |
//| поднялись выше -10, то стоплосс - на -25, если поднимемся выще   |
//| -5, то стоплосс перенесем на -10, при -2 (спрэд) стоп на -5      |
//| работаем только с одной позицией одновременно                    |
//+------------------------------------------------------------------+
void TrailingRatchetB(int ticket,int pf_level_1,int pf_level_2,int pf_level_3,int ls_level_1,int ls_level_2,int ls_level_3,bool trlinloss)
   {
    
   // проверяем переданные значения
   if ((ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET)) || (pf_level_2<=pf_level_1) || (pf_level_3<=pf_level_2) || 
   (pf_level_3<=pf_level_1) || (pf_level_2-pf_level_1<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) || (pf_level_3-pf_level_2<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) ||
   (pf_level_1<=MarketInfo(Symbol(),MODE_STOPLEVEL)))
      {
      Print("Трейлинг функцией TrailingRatchetB() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      }
                
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      double dBid = MarketInfo(Symbol(),MODE_BID);
      
      // Работаем на участке профитов
      
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_3+спрэд", стоплосс переносим в "pf_level_2+спрэд"
      if ((dBid-OrderOpenPrice())>=pf_level_3*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + pf_level_2 *Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + pf_level_2*Point,OrderTakeProfit(),OrderExpiration());
         }
      else
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_2+спрэд", стоплосс переносим в "pf_level_1+спрэд"
      if ((dBid-OrderOpenPrice())>=pf_level_2*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + pf_level_1*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + pf_level_1*Point,OrderTakeProfit(),OrderExpiration());
         }
      else        
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_1+спрэд", стоплосс переносим в +1 ("открытие + спрэд")
      if ((dBid-OrderOpenPrice())>=pf_level_1*Point)
      // если стоплосс не определен или хуже чем "открытие+1"
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + 1*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + 1*Point,OrderTakeProfit(),OrderExpiration());
         }

      // Работаем на участке лоссов
      if (trlinloss==true)      
         {
         // Глобальная переменная терминала содержит значение самого уровня убытка (ls_level_n), ниже которого опускался курс
         // (если он после этого поднимается выше, устанавливаем стоплосс на ближайшем более глубоком уровне убытка (если это не начальный стоплосс позиции)
         // Создаём глобальную переменную (один раз)
         if(!GlobalVariableCheck("zeticket")) 
            {
            GlobalVariableSet("zeticket",ticket);
            // при создании присвоим ей "0"
            GlobalVariableSet("dpstlslvl",0);
            }
         // если работаем с новой сделкой (новый тикет), затираем значение dpstlslvl
         if (GlobalVariableGet("zeticket")!=ticket)
            {
            GlobalVariableSet("dpstlslvl",0);
            GlobalVariableSet("zeticket",ticket);
            }
      
         // убыточным считаем участок ниже курса открытия и до первого уровня профита
         if ((dBid-OrderOpenPrice())<pf_level_1*Point)         
            {
            // если (текущий_курс лучше/равно открытие) и (dpstlslvl>=ls_level_1), стоплосс - на ls_level_1
            if (dBid>=OrderOpenPrice()) 
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_1*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_1*Point,OrderTakeProfit(),OrderExpiration());
      
            // если (текущий_курс лучше уровня_убытка_1) и (dpstlslvl>=ls_level_1), стоплосс - на ls_level_2
            if ((dBid>=OrderOpenPrice()-ls_level_1*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_1))
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_2*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_2*Point,OrderTakeProfit(),OrderExpiration());
      
            // если (текущий_курс лучше уровня_убытка_2) и (dpstlslvl>=ls_level_2), стоплосс - на ls_level_3
            if ((dBid>=OrderOpenPrice()-ls_level_2*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_2))
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_3*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_3*Point,OrderTakeProfit(),OrderExpiration());
      
            // проверим/обновим значение наиболее глубокой "взятой" лоссовой "ступеньки"
            // если "текущий_курс-курс открытия+спрэд" меньше 0, 
            if ((dBid-OrderOpenPrice()+MarketInfo(Symbol(),MODE_SPREAD)*Point)<0)
            // проверим, не меньше ли он того или иного уровня убытка
               {
               if (dBid<=OrderOpenPrice()-ls_level_3*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_3)
               GlobalVariableSet("dpstlslvl",ls_level_3);
               else
               if (dBid<=OrderOpenPrice()-ls_level_2*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_2)
               GlobalVariableSet("dpstlslvl",ls_level_2);   
               else
               if (dBid<=OrderOpenPrice()-ls_level_1*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_1)
               GlobalVariableSet("dpstlslvl",ls_level_1);
               }
            } // end of "if ((dBid-OrderOpenPrice())<pf_level_1*Point)"
         } // end of "if (trlinloss==true)"
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      double dAsk = MarketInfo(Symbol(),MODE_ASK);
      
      // Работаем на участке профитов
      
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_3+спрэд", стоплосс переносим в "pf_level_2+спрэд"
      if ((OrderOpenPrice()-dAsk)>=pf_level_3*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (pf_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (pf_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }
      else
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_2+спрэд", стоплосс переносим в "pf_level_1+спрэд"
      if ((OrderOpenPrice()-dAsk)>=pf_level_2*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (pf_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (pf_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }
      else        
      // если разница "текущий_курс-курс_открытия" больше чем "pf_level_1+спрэд", стоплосс переносим в +1 ("открытие + спрэд")
      if ((OrderOpenPrice()-dAsk)>=pf_level_1*Point)
      // если стоплосс не определен или хуже чем "открытие+1"
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (1 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }

      // Работаем на участке лоссов
      if (trlinloss==true)      
         {
         // Глобальная переменная терминала содержит значение самого уровня убытка (ls_level_n), ниже которого опускался курс
         // (если он после этого поднимается выше, устанавливаем стоплосс на ближайшем более глубоком уровне убытка (если это не начальный стоплосс позиции)
         // Создаём глобальную переменную (один раз)
         if(!GlobalVariableCheck("zeticket")) 
            {
            GlobalVariableSet("zeticket",ticket);
            // при создании присвоим ей "0"
            GlobalVariableSet("dpstlslvl",0);
            }
         // если работаем с новой сделкой (новый тикет), затираем значение dpstlslvl
         if (GlobalVariableGet("zeticket")!=ticket)
            {
            GlobalVariableSet("dpstlslvl",0);
            GlobalVariableSet("zeticket",ticket);
            }
      
         // убыточным считаем участок ниже курса открытия и до первого уровня профита
         if ((OrderOpenPrice()-dAsk)<pf_level_1*Point)         
            {
            // если (текущий_курс лучше/равно открытие) и (dpstlslvl>=ls_level_1), стоплосс - на ls_level_1
            if (dAsk<=OrderOpenPrice()) 
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // если (текущий_курс лучше уровня_убытка_1) и (dpstlslvl>=ls_level_1), стоплосс - на ls_level_2
            if ((dAsk<=OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_1))
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // если (текущий_курс лучше уровня_убытка_2) и (dpstlslvl>=ls_level_2), стоплосс - на ls_level_3
            if ((dAsk<=OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_2))
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_3 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_3 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // проверим/обновим значение наиболее глубокой "взятой" лоссовой "ступеньки"
            // если "текущий_курс-курс открытия+спрэд" меньше 0, 
            if ((OrderOpenPrice()-dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)<0)
            // проверим, не меньше ли он того или иного уровня убытка
               {
               if (dAsk>=OrderOpenPrice()+(ls_level_3+MarketInfo(Symbol(),MODE_SPREAD))*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_3)
               GlobalVariableSet("dpstlslvl",ls_level_3);
               else
               if (dAsk>=OrderOpenPrice()+(ls_level_2+MarketInfo(Symbol(),MODE_SPREAD))*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_2)
               GlobalVariableSet("dpstlslvl",ls_level_2);   
               else
               if (dAsk>=OrderOpenPrice()+(ls_level_1+MarketInfo(Symbol(),MODE_SPREAD))*Point)
               if (GlobalVariableGet("dpstlslvl")<ls_level_1)
               GlobalVariableSet("dpstlslvl",ls_level_1);
               }
            } // end of "if ((dBid-OrderOpenPrice())<pf_level_1*Point)"
         } // end of "if (trlinloss==true)"
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО ЦЕНВОМУ КАНАЛУ                                       |
//| Функции передаётся тикет позиции, период (кол-во баров) для      | 
//| рассчета верхней и нижней границ канала, отступ (пунктов), на    |
//| котором размещается стоплосс от границы канала                   |
//| Трейлинг по закрывшимся барам.                                   |
//+------------------------------------------------------------------+
void TrailingByPriceChannel(int iTicket,int iBars_n,int iIndent)
   {     
   
   // проверяем переданные значения
   if ((iBars_n<1) || (iIndent<0) || (iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)))
      {
      Print("Трейлинг функцией TrailingByPriceChannel() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   double   dChnl_max; // верхняя граница канала
   double   dChnl_min; // нижняя граница канала
   
   // определяем макс.хай и мин.лоу за iBars_n баров начиная с [1] (= верхняя и нижняя границы ценового канала)
   dChnl_max = High[iHighest(Symbol(),0,2,iBars_n,1)] + (iIndent+MarketInfo(Symbol(),MODE_SPREAD))*Point;
   dChnl_min = Low[iLowest(Symbol(),0,1,iBars_n,1)] - iIndent*Point;   
   
   // если длинная позиция, и её стоплосс хуже (ниже нижней границы канала либо не определен, ==0), модифицируем его
   if (OrderType()==OP_BUY)
      {
      if ((OrderStopLoss()<dChnl_min) && (dChnl_min<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dChnl_min,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
   
   // если позиция - короткая, и её стоплосс хуже (выше верхней границы канала или не определён, ==0), модифицируем его
   if (OrderType()==OP_SELL)
      {
      if (((OrderStopLoss()==0) || (OrderStopLoss()>dChnl_max)) && (dChnl_min>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dChnl_max,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ ПО СКОЛЬЗЯЩЕМУ СРЕДНЕМУ                                 |
//| Функции передаётся тикет позиции и параметры средней (таймфрейм, | 
//| период, тип, сдвиг относительно графика, метод сглаживания,      |
//| составляющая OHCL для построения, № бара, на котором берется     |
//| значение средней.                                                |
//+------------------------------------------------------------------+

//    Допустимые варианты ввода:   
//    iTmFrme:    1 (M1), 5 (M5), 15 (M15), 30 (M30), 60 (H1), 240 (H4), 1440 (D), 10080 (W), 43200 (MN);
//    iMAPeriod:  2-infinity, целые числа; 
//    iMAShift:   целые положительные или отрицательные числа, а также 0;
//    MAMethod:   0 (MODE_SMA), 1 (MODE_EMA), 2 (MODE_SMMA), 3 (MODE_LWMA);
//    iApplPrice: 0 (PRICE_CLOSE), 1 (PRICE_OPEN), 2 (PRICE_HIGH), 3 (PRICE_LOW), 4 (PRICE_MEDIAN), 5 (PRICE_TYPICAL), 6 (PRICE_WEIGHTED)
//    iShift:     0-Bars, целые числа;
//    iIndent:    0-infinity, целые числа;

void TrailingByMA(int iTicket,int iTmFrme,int iMAPeriod,int iMAShift,int MAMethod,int iApplPrice,int iShift,int iIndent)
   {     
   
   // проверяем переданные значения
   if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || ((iTmFrme!=1) && (iTmFrme!=5) && (iTmFrme!=15) && (iTmFrme!=30) && (iTmFrme!=60) && (iTmFrme!=240) && (iTmFrme!=1440) && (iTmFrme!=10080) && (iTmFrme!=43200)) ||
   (iMAPeriod<2) || (MAMethod<0) || (MAMethod>3) || (iApplPrice<0) || (iApplPrice>6) || (iShift<0) || (iIndent<0))
      {
      Print("Трейлинг функцией TrailingByMA() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 

   double   dMA; // значение скользящего среднего с переданными параметрами
   
   // определим значение МА с переданными функции параметрами
   dMA = iMA(Symbol(),iTmFrme,iMAPeriod,iMAShift,MAMethod,iApplPrice,iShift);
         
   // если длинная позиция, и её стоплосс хуже значения среднего с отступом в iIndent пунктов, модифицируем его
   if (OrderType()==OP_BUY)
      {
      if ((OrderStopLoss()<dMA-iIndent*Point) && (dMA-iIndent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dMA-iIndent*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
   
   // если позиция - короткая, и её стоплосс хуже (выше верхней границы канала или не определён, ==0), модифицируем его
   if (OrderType()==OP_SELL)
      {
      if (((OrderStopLoss()==0) || (OrderStopLoss()>dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point)) && (dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point,OrderTakeProfit(),OrderExpiration()))
         Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ "ПОЛОВИНЯЩИЙ"                                           |
//| По закрытии очередного периода (бара) подтягиваем стоплосс на    |
//| половину (но можно и любой иной коэффициент) дистанции, прой-    |
//| денной курсом (т.е., например, по закрытии суток профит +55 п. - |
//| стоплосс переносим в 55/2=27 п. Если по закрытии след.           |
//| суток профит достиг, допустим, +80 п., то стоплосс переносим на  |
//| половину (напр.) расстояния между тек. стоплоссом и курсом на    |
//| закрытии бара - 27 + (80-27)/2 = 27 + 53/2 = 27 + 26 = 53 п.     |
//| iTicket - тикет позиции; iTmFrme - таймфрейм (в минутах, цифрами |
//| dCoeff - "коэффициент поджатия", в % от 0.01 до 1 (в последнем   |
//| случае стоплосс будет перенесен (если получится) вплотную к тек. |
//| курсу и позиция, скорее всего, сразу же закроется)               |
//| bTrlinloss - стоит ли тралить на лоссовом участке - если да, то  |
//| по закрытию очередного бара расстояние между стоплоссом (в т.ч.  |
//| "до" безубытка) и текущим курсом будет сокращаться в dCoeff раз  |
//| чтобы посл. вариант работал, обязательно должен быть определён   |
//| стоплосс (не равен 0)                                            |
//+------------------------------------------------------------------+

void TrailingFiftyFifty(int iTicket,int iTmFrme,double dCoeff,bool bTrlinloss)
   { 
   // активируем трейлинг только по закрытии бара
   if (sdtPrevtime == iTime(Symbol(),iTmFrme,0)) return(0);
   else
      {
      sdtPrevtime = iTime(Symbol(),iTmFrme,0);             
      
      // проверяем переданные значения
      if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || 
      ((iTmFrme!=1) && (iTmFrme!=5) && (iTmFrme!=15) && (iTmFrme!=30) && (iTmFrme!=60) && (iTmFrme!=240) && 
      (iTmFrme!=1440) && (iTmFrme!=10080) && (iTmFrme!=43200)) || (dCoeff<0.01) || (dCoeff>1.0))
         {
         Print("Трейлинг функцией TrailingFiftyFifty() невозможен из-за некорректности значений переданных ей аргументов.");
         return(0);
         }
         
      // начинаем тралить - с первого бара после открывающего (иначе при bTrlinloss сразу же после открытия 
      // позиции стоплосс будет перенесен на половину расстояния между стоплоссом и курсом открытия)
      // т.е. работаем только при условии, что с момента OrderOpenTime() прошло не менее iTmFrme минут
      if (iTime(Symbol(),iTmFrme,0)>OrderOpenTime())
      {         
      
      double dBid = MarketInfo(Symbol(),MODE_BID);
      double dAsk = MarketInfo(Symbol(),MODE_ASK);
      double dNewSl;
      double dNexMove;     
      
      // для длинной позиции переносим стоплосс на dCoeff дистанции от курса открытия до Bid на момент открытия бара
      // (если такой стоплосс лучше имеющегося и изменяет стоплосс в сторону профита)
      if (OrderType()==OP_BUY)
         {
         if ((bTrlinloss) && (OrderStopLoss()!=0))
            {
            dNexMove = NormalizeDouble(dCoeff*(dBid-OrderStopLoss()),Digits);
            dNewSl = NormalizeDouble(OrderStopLoss()+dNexMove,Digits);            
            }
         else
            {
            // если стоплосс ниже курса открытия, то тралим "от курса открытия"
            if (OrderOpenPrice()>OrderStopLoss())
               {
               dNexMove = NormalizeDouble(dCoeff*(dBid-OrderOpenPrice()),Digits);                 
               //Print("dNexMove = ",dCoeff,"*(",dBid,"-",OrderOpenPrice(),")");
               dNewSl = NormalizeDouble(OrderOpenPrice()+dNexMove,Digits);
               //Print("dNewSl = ",OrderOpenPrice(),"+",dNexMove);
               }
         
            // если стоплосс выше курса открытия, тралим от стоплосса
            if (OrderStopLoss()>=OrderOpenPrice())
               {
               dNexMove = NormalizeDouble(dCoeff*(dBid-OrderStopLoss()),Digits);
               dNewSl = NormalizeDouble(OrderStopLoss()+dNexMove,Digits);
               }                                      
            }
            
         // стоплосс перемещаем только в случае, если новый стоплосс лучше текущего и если смещение - в сторону профита
         // (при первом поджатии, от курса открытия, новый стоплосс может быть лучше имеющегося, и в то же время ниже 
         // курса открытия (если dBid ниже последнего) 
         if ((dNewSl>OrderStopLoss()) && (dNexMove>0) && ((dNewSl<Bid- MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)))
            {
            if (!OrderModify(OrderTicket(),OrderOpenPrice(),dNewSl,OrderTakeProfit(),OrderExpiration(),Red))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }       
      
      // действия для короткой позиции   
      if (OrderType()==OP_SELL)
         {
         if ((bTrlinloss) && (OrderStopLoss()!=0))
            {
            dNexMove = NormalizeDouble(dCoeff*(OrderStopLoss()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);
            dNewSl = NormalizeDouble(OrderStopLoss()-dNexMove,Digits);            
            }
         else
            {         
            // если стоплосс выше курса открытия, то тралим "от курса открытия"
            if (OrderOpenPrice()<OrderStopLoss())
               {
               dNexMove = NormalizeDouble(dCoeff*(OrderOpenPrice()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);                 
               dNewSl = NormalizeDouble(OrderOpenPrice()-dNexMove,Digits);
               }
         
            // если стоплосс нижу курса открытия, тралим от стоплосса
            if (OrderStopLoss()<=OrderOpenPrice())
               {
               dNexMove = NormalizeDouble(dCoeff*(OrderStopLoss()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);
               dNewSl = NormalizeDouble(OrderStopLoss()-dNexMove,Digits);
               }                  
            }
         
         // стоплосс перемещаем только в случае, если новый стоплосс лучше текущего и если смещение - в сторону профита
         if ((dNewSl<OrderStopLoss()) && (dNexMove>0) && (dNewSl>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(OrderTicket(),OrderOpenPrice(),dNewSl,OrderTakeProfit(),OrderExpiration(),Blue))
            Print("Не удалось модифицировать стоплосс ордера №",OrderTicket(),". Ошибка: ",GetLastError());
            }
         }               
      }
      }   
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ KillLoss                                                |
//| Применяется на участке лоссов. Суть: стоплосс движется навстречу |
//| курсу со скоростью движения курса х коэффициент (dSpeedCoeff).   |
//| При этом коэффициент можно "привязать" к скорости увеличения     |
//| убытка - так, чтобы при быстром росте лосса потерять меньше. При |
//| коэффициенте = 1 стоплосс сработает ровно посредине между уров-  |
//| нем стоплосса и курсом на момент запуска функции, при коэфф.>1   |
//| точка встречи курса и стоплосса будет смещена в сторону исход-   |
//| ного положения курса, при коэфф.<1 - наоборот, ближе к исходно-  |
//| му стоплоссу.                                                    |
//+------------------------------------------------------------------+

void KillLoss(int iTicket,double dSpeedCoeff)
   {   
   // проверяем переданные значения
   if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || (dSpeedCoeff<0.1))
      {
      Print("Трейлинг функцией KillLoss() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      }           
      
   double dStopPriceDiff; // расстояние (пунктов) между курсом и стоплоссом   
   double dToMove; // кол-во пунктов, на которое следует переместить стоплосс   
   // текущий курс
   double dBid = MarketInfo(OrderSymbol(),MODE_BID);
   double dAsk = MarketInfo(OrderSymbol(),MODE_ASK);      
   
   // текущее расстояние между курсом и стоплоссом
   if (OrderType()==OP_BUY) dStopPriceDiff = dBid - OrderStopLoss();
   if (OrderType()==OP_SELL) dStopPriceDiff = (OrderStopLoss() + MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT)) - dAsk;                  
   
   // проверяем, если тикет != тикету, с которым работали раньше, запоминаем текущее расстояние между курсом и стоплоссом
   if (GlobalVariableGet("zeticket")!=iTicket)
      {
      GlobalVariableSet("sldiff",dStopPriceDiff);      
      GlobalVariableSet("zeticket",iTicket);
      }
   else
      {                                   
      // итак, у нас есть коэффициент ускорения изменения курса
      // на каждый пункт, который проходит курс в сторону лосса, 
      // мы должны переместить стоплосс ему на встречу на dSpeedCoeff раз пунктов
      // (например, если лосс увеличился на 3 пункта за тик, dSpeedCoeff = 1.5, то
      // стоплосс подтягиваем на 3 х 1.5 = 4.5, округляем - 5 п. Если подтянуть не 
      // удаётся (слишком близко), ничего не делаем.            
      
      // кол-во пунктов, на которое приблизился курс к стоплоссу с момента предыдущей проверки (тика, по идее)
      dToMove = (GlobalVariableGet("sldiff") - dStopPriceDiff) / MarketInfo(OrderSymbol(),MODE_POINT);
      
      // записываем новое значение, но только если оно уменьшилось
      if (dStopPriceDiff<GlobalVariableGet("sldiff"))
      GlobalVariableSet("sldiff",dStopPriceDiff);
      
      // дальше действия на случай, если расстояние уменьшилось (т.е. курс приблизился к стоплоссу, убыток растет)
      if (dToMove>0)
         {       
         // стоплосс, соответственно, нужно также передвинуть на такое же расстояние, но с учетом коэфф. ускорения
         dToMove = MathRound(dToMove * dSpeedCoeff) * MarketInfo(OrderSymbol(),MODE_POINT);                 
      
         // теперь проверим, можем ли мы подтянуть стоплосс на такое расстояние
         if (OrderType()==OP_BUY)
            {
            if (dBid - (OrderStopLoss() + dToMove)>MarketInfo(OrderSymbol(),MODE_STOPLEVEL)* MarketInfo(OrderSymbol(),MODE_POINT))
            OrderModify(iTicket,OrderOpenPrice(),OrderStopLoss() + dToMove,OrderTakeProfit(),OrderExpiration());            
            }
         if (OrderType()==OP_SELL)
            {
            if ((OrderStopLoss() - dToMove) - dAsk>MarketInfo(OrderSymbol(),MODE_STOPLEVEL) * MarketInfo(OrderSymbol(),MODE_POINT))
            OrderModify(iTicket,OrderOpenPrice(),OrderStopLoss() - dToMove,OrderTakeProfit(),OrderExpiration());
            }      
         }
      }            
   }
   
//+------------------------------------------------------------------+ 