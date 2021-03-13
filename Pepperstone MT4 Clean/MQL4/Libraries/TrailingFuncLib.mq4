//+------------------------------------------------------------------+
//|                                                  TrailingAll.mq4 |
//|                                                              I_D |
//|             ���� ��� ���������� ���������: http://www.mymmk.com/ |
//+------------------------------------------------------------------+
#property copyright "I_D / ���� ������"
#property link      "http://www.mymmk.com/ ���� ��� ���������� ���������"
#property library

static datetime sdtPrevtime = 0;

//+------------------------------------------------------------------+
//| �������� �� ���������                                            |
//| ������� ��������� ����� �������, ���������� ����� � ��������,   |
//| � ������ (�������) - ���������� �� ����. (���.) �����, ��        |
//| ������� ����������� �������� (�� 0), trlinloss - ������� �� �    |
//| ���� �������                                                     |
//+------------------------------------------------------------------+
void TrailingByFractals(int ticket,int tmfrm,int frktl_bars,int indent,bool trlinloss)
   {
   int i, z; // counters
   int extr_n; // ����� ���������� ���������� frktl_bars-������� �������� 
   double temp; // ��������� ����������
   int after_x, be4_x; // ������ ����� � �� ���� ��������������
   int ok_be4, ok_after; // ����� ������������ ������� (1 - �����������, 0 - ���������)
   int sell_peak_n, buy_peak_n; // ������ ����������� ��������� ��������� �� ������� (��� �������� ��.���.) � ������� �������������   
   
   // ��������� ���������� ��������
   if ((frktl_bars<=3) || (indent<0) || (ticket==0) || ((tmfrm!=1) && (tmfrm!=5) && (tmfrm!=15) && (tmfrm!=30) && (tmfrm!=60) && (tmfrm!=240) && (tmfrm!=1440) && (tmfrm!=10080) && (tmfrm!=43200)) || (!OrderSelect(ticket,SELECT_BY_TICKET)))
      {
      Print("�������� �������� TrailingByFractals() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 
   
   temp = frktl_bars;
      
   if (MathMod(frktl_bars,2)==0)
   extr_n = temp/2;
   else                
   extr_n = MathRound(temp/2);
      
   // ����� �� � ����� ���������� ��������
   after_x = frktl_bars - extr_n;
   if (MathMod(frktl_bars,2)!=0)
   be4_x = frktl_bars - extr_n;
   else
   be4_x = frktl_bars - extr_n - 1;    
   
   // ���� ������� ������� (OP_BUY), ������� ��������� ������� �� ������� (�.�. ��������� "����")
   if (OrderType()==OP_BUY)
      {
      // ������� ��������� ������� �� �������
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
     
      // ���� ������� � ������
      if (trlinloss==true)
         {
         // ���� ����� �������� ����� ���������� (� �.�. ���� �������� == 0, �� ���������)
         // � ����� ���� ���� �� ������� ������, �� � ���� �������� ��� �� ��� ��������� �� ��������������� �������         
         if ((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      // ���� ������� ������ � �������, ��
      else
         {
         // ���� ����� �������� ����� ���������� � ����� ��������, � ����� �� ������� ������ � �������� �����
         if ((iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderStopLoss()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point>OrderOpenPrice()) && (iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iLow(Symbol(),tmfrm,sell_peak_n)-indent*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }
      
   // ���� �������� ������� (OP_SELL), ������� ��������� ������� �� ������� (�.�. ��������� "�����")
   if (OrderType()==OP_SELL)
      {
      // ������� ��������� ������� �� �������
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
      
      // ���� ������� � ������
      if (trlinloss==true)
         {
         if (((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0)) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }      
      // ���� ������� ������ � �������, ��
      else
         {
         // ���� ����� �������� ����� ���������� � ����� ��������
         if ((((iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderStopLoss()) || (OrderStopLoss()==0))) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point<OrderOpenPrice()) && (iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),iHigh(Symbol(),tmfrm,buy_peak_n)+(indent+MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �� ����� N ������                                       |
//| ������� ��������� ����� �������, ���������� �����, �� �����     |
//| ������� ���������� ������������� (�� 1 � ������) � ������        |
//| (�������) - ���������� �� ����. (���.) �����, �� �������         |
//| ����������� �������� (�� 0), trlinloss - ������� �� � �����      | 
//+------------------------------------------------------------------+
void TrailingByShadows(int ticket,int tmfrm,int bars_n, int indent,bool trlinloss)
   {  
   
   int i; // counter
   double new_extremum;
   
   // ��������� ���������� ��������
   if ((bars_n<1) || (indent<0) || (ticket==0) || ((tmfrm!=1) && (tmfrm!=5) && (tmfrm!=15) && (tmfrm!=30) && (tmfrm!=60) && (tmfrm!=240) && (tmfrm!=1440) && (tmfrm!=10080) && (tmfrm!=43200)) || (!OrderSelect(ticket,SELECT_BY_TICKET)))
      {
      Print("�������� �������� TrailingByShadows() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 
   
   // ���� ������� ������� (OP_BUY), ������� ������� bars_n ������
   if (OrderType()==OP_BUY)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iLow(Symbol(),tmfrm,i);
         else 
         if (new_extremum>iLow(Symbol(),tmfrm,i)) new_extremum = iLow(Symbol(),tmfrm,i);
         }         
      
      // ���� ������ � � ���� �������
      if (trlinloss==true)
         {
         // ���� ��������� �������� "�����" �������� ��������� �������, ��������� 
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum - indent*Point,OrderTakeProfit(),OrderExpiration()))            
         Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
         }
      else
         {
         // ���� ����� �������� �� ������ ����� �����������, �� � ����� �������� �������
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum - indent*Point)>OrderOpenPrice()) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum-indent*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
         }
      }
      
   // ���� �������� ������� (OP_SELL), ������� ������� bars_n ������
   if (OrderType()==OP_SELL)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iHigh(Symbol(),tmfrm,i);
         else 
         if (new_extremum<iHigh(Symbol(),tmfrm,i)) new_extremum = iHigh(Symbol(),tmfrm,i);
         }         
           
      // ���� ������ � � ���� �������
      if (trlinloss==true)
         {
         // ���� ��������� �������� "�����" �������� ��������� �������, ��������� 
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
         }
      else
         {
         // ���� ����� �������� �� ������ ����� �����������, �� � ����� �������� �������
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderOpenPrice()) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
         }      
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �����������-������������                                |
//| ������� ��������� ����� �������, ���������� �� ����� ��������,  |
//| �� ������� �������� ����������� (�������) � "���", � ������� ��  |
//| ����������� (�������)                                            |
//| ������: ��� +30 ���� �� +10, ��� +40 - ���� �� +20 � �.�.        |
//+------------------------------------------------------------------+

void TrailingStairs(int ticket,int trldistance,int trlstep)
   { 
   
   double nextstair; // ��������� �������� �����, ��� ������� ����� ������ ��������

   // ��������� ���������� ��������
   if ((trldistance<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trlstep<1) || (trldistance<trlstep) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("�������� �������� TrailingStairs() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 
   
   // ���� ������� ������� (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // �����������, ��� ����� �������� ����� ������� ��������������� ��������
      // ���� �������� ���� �������� ��� ����� 0 (�� ���������), �� ��������� ������� = ���� �������� + trldistance + �����
      if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()))
      nextstair = OrderOpenPrice() + trldistance*Point;
         
      // ����� ��������� ������� = ������� �������� + trldistance + trlstep + �����
      else
      nextstair = OrderStopLoss() + trldistance*Point;

      // ���� ������� ���� (Bid) >= nextstair � ����� �������� ����� ����� ��������, ������������ ���������
      if (Bid>=nextstair)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()) && (OrderOpenPrice() + trlstep*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)) 
            {
            if (!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + trlstep*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      else
         {
         if (!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss() + trlstep*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
      
   // ���� �������� ������� (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // �����������, ��� ����� �������� ����� ������� ��������������� ��������
      // ���� �������� ���� �������� ��� ����� 0 (�� ���������), �� ��������� ������� = ���� �������� + trldistance + �����
      if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()))
      nextstair = OrderOpenPrice() - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
      
      // ����� ��������� ������� = ������� �������� + trldistance + trlstep + �����
      else
      nextstair = OrderStopLoss() - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
       
      // ���� ������� ���� (���) >= nextstair � ����� �������� ����� ����� ��������, ������������ ���������
      if (Ask<=nextstair)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()) && (OrderOpenPrice() - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      else
         {
         if (!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()- (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �����������-��������������                              |
//| ������� ��������� ����� �������, �������� �������� (�������) �  |
//| 2 "������" (�������� �������, �������), ��� ������� ��������     |
//| ���������, � ��������������� �������� ��������� (�������)        |
//| ������: �������� �������� 30 �., ��� +50 - 20 �., +80 � ������ - |
//| �� ���������� � 10 �������.                                      |
//+------------------------------------------------------------------+

void TrailingUdavka(int ticket,int trl_dist_1,int level_1,int trl_dist_2,int level_2,int trl_dist_3)
   {  
   
   double newstop = 0; // ����� ��������
   double trldist; // ���������� ��������� (� ����������� �� "�����������" ����� = trl_dist_1, trl_dist_2 ��� trl_dist_3)

   // ��������� ���������� ��������
   if ((trl_dist_1<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_2<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trl_dist_3<MarketInfo(Symbol(),MODE_STOPLEVEL)) || 
   (level_1<=trl_dist_1) || (level_2<=trl_dist_1) || (level_2<=level_1) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("�������� �������� TrailingUdavka() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 
   
   // ���� ������� ������� (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // ���� ������ <=trl_dist_1, �� trldist=trl_dist_1, ���� ������>trl_dist_1 && ������<=level_1*Point ...
      if ((Bid-OrderOpenPrice())<=level_1*Point) trldist = trl_dist_1;
      if (((Bid-OrderOpenPrice())>level_1*Point) && ((Bid-OrderOpenPrice())<=level_2*Point)) trldist = trl_dist_2;
      if ((Bid-OrderOpenPrice())>level_2*Point) trldist = trl_dist_3; 
            
      // ���� �������� = 0 ��� ������ ����� ��������, �� ���� ���.���� (Bid) ������/����� ��������� ����_��������+�����.���������
      if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice()))
         {
         if (Bid>(OrderOpenPrice() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }

      // �����: ���� ������� ���� (Bid) ������/����� ��������� �������_��������+���������� ���������, 
      else
         {
         if (Bid>(OrderStopLoss() + trldist*Point))
         newstop = Bid -  trldist*Point;
         }
      
      // ������������ ��������
      if ((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
      
   // ���� �������� ������� (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // ���� ������ <=trl_dist_1, �� trldist=trl_dist_1, ���� ������>trl_dist_1 && ������<=level_1*Point ...
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_1*Point) trldist = trl_dist_1;
      if (((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_1*Point) && ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))<=level_2*Point)) trldist = trl_dist_2;
      if ((OrderOpenPrice()-(Ask + MarketInfo(Symbol(),MODE_SPREAD)*Point))>level_2*Point) trldist = trl_dist_3; 
            
      // ���� �������� = 0 ��� ������ ����� ��������, �� ���� ���.���� (Ask) ������/����� ��������� ����_��������+�����.���������
      if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice()))
         {
         if (Ask<(OrderOpenPrice() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask + trldist*Point;
         }

      // �����: ���� ������� ���� (Bid) ������/����� ��������� �������_��������+���������� ���������, 
      else
         {
         if (Ask<(OrderStopLoss() - (trldist + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         newstop = Ask +  trldist*Point;
         }
            
       // ������������ ��������
      if (newstop>0)
         {
         if (((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice())) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))  
               {
               if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
               Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
               }
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �� �������                                              |
//| ������� ��������� ����� �������, �������� (�����), � �������,   |
//| ������������� �������� � ��� ��������� (�� ������� �������       |
//| ������������ ��������, trlinloss - ������ �� � ������            |
//| (�.�. � ����������� ���������� ����������� ���� �� �����        |
//| ��������, � ����� � � �������, ���� ������ � �������)            |
//+------------------------------------------------------------------+
void TrailingByTime(int ticket,int interval,int trlstep,bool trlinloss)
   {
      
   // ��������� ���������� ��������
   if ((ticket==0) || (interval<1) || (trlstep<1) || !OrderSelect(ticket,SELECT_BY_TICKET))
      {
      Print("�������� �������� TrailingByTime() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      }
      
   double minpast; // ���-�� ������ ����� �� �������� ������� �� �������� ������� 
   double times2change; // ���-�� ���������� interval � ������� �������� ������� (�.�. ������� ��� ������ ��� ���� ��������� ��������) 
   double newstop; // ����� �������� ��������� (�������� ���-�� ���������, ������� ������ ���� ����� �����)
   
   // ����������, ������� ������� ������ � ������� �������� �������
   minpast = (TimeCurrent() - OrderOpenTime()) / 60;
      
   // ������� ��� ����� ���� ����������� ��������
   times2change = MathFloor(minpast / interval);
         
   // ���� ������� ������� (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // ���� ������ � ������, �� ��������� �� ��������� (���� �� �� 0, ���� 0 - �� ��������)
      if (trlinloss==true)
         {
         if (OrderStopLoss()==0) newstop = OrderOpenPrice() + times2change*(trlstep*Point);
         else newstop = OrderStopLoss() + times2change*(trlstep*Point); 
         }
      else
      // ����� - �� ����� �������� �������
      newstop = OrderOpenPrice() + times2change*(trlstep*Point); 
         
      if (times2change>0)
         {
         if ((newstop>OrderStopLoss()) && (newstop<Bid- MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }
      
   // ���� �������� ������� (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      // ���� ������ � ������, �� ��������� �� ��������� (���� �� �� 0, ���� 0 - �� ��������)
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
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         else
         if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �� ATR (Average True Range, ������� �������� ��������)  |
//| ������� ��������� ����� �������, ������ ��R � �����������, ��   |
//| ������� ���������� ATR. �.�. �������� "�������" �� ����������    |
//| ATR � N �� �������� �����; ������� - �� ����� ���� (�.�. �� ���� |
//| �������� ���������� ����)                                        |
//+------------------------------------------------------------------+
void TrailingByATR(int ticket,int atr_timeframe,int atr1_period,int atr1_shift,int atr2_period,int atr2_shift,double coeff,bool trlinloss)
   {
   // ��������� ���������� ��������   
   if ((ticket==0) || (atr1_period<1) || (atr2_period<1) || (coeff<=0) || (!OrderSelect(ticket,SELECT_BY_TICKET)) || 
   ((atr_timeframe!=1) && (atr_timeframe!=5) && (atr_timeframe!=15) && (atr_timeframe!=30) && (atr_timeframe!=60) && 
   (atr_timeframe!=240) && (atr_timeframe!=1440) && (atr_timeframe!=10080) && (atr_timeframe!=43200)) || (atr1_shift<0) || (atr2_shift<0))
      {
      Print("�������� �������� TrailingByATR() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      }
   
   double curr_atr1; // ������� �������� ATR - 1
   double curr_atr2; // ������� �������� ATR - 2
   double best_atr; // ������� �� �������� ATR
   double atrXcoeff; // ��������� ��������� �������� �� ATR �� �����������
   double newstop; // ����� ��������
   
   // ������� �������� ATR-1, ATR-2
   curr_atr1 = iATR(Symbol(),atr_timeframe,atr1_period,atr1_shift);
   curr_atr2 = iATR(Symbol(),atr_timeframe,atr2_period,atr2_shift);
   
   // ������� �� ��������
   best_atr = MathMax(curr_atr1,curr_atr2);
   
   // ����� ��������� �� �����������
   atrXcoeff = best_atr * coeff;
              
   // ���� ������� ������� (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // ����������� �� �������� ����� (����� ��������)
      newstop = Bid - atrXcoeff;           
      
      // ���� trlinloss==true (�.�. ������� ������� � ���� ������), ��
      if (trlinloss==true)      
         {
         // ���� �������� �����������, �� ������ � ����� ������
         if ((OrderStopLoss()==0) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         // ����� ������ ������ ���� ����� ���� ����� �������
         else
            {
            if ((newstop>OrderStopLoss()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      else
         {
         // ���� �������� �����������, �� ������, ���� ���� ����� ��������
         if ((OrderStopLoss()==0) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         // ���� ���� �� ����� 0, �� ������ ���, ���� �� ����� ����������� � ����� ��������
         else
            {
            if ((newstop>OrderStopLoss()) && (newstop>OrderOpenPrice()) && (newstop<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }
      
   // ���� �������� ������� (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      // ����������� �� �������� ����� (����� ��������)
      newstop = Ask + atrXcoeff;
      
      // ���� trlinloss==true (�.�. ������� ������� � ���� ������), ��
      if (trlinloss==true)      
         {
         // ���� �������� �����������, �� ������ � ����� ������
         if ((OrderStopLoss()==0) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         // ����� ������ ������ ���� ����� ���� ����� �������
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      else
         {
         // ���� �������� �����������, �� ������, ���� ���� ����� ��������
         if ((OrderStopLoss()==0) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         // ���� ���� �� ����� 0, �� ������ ���, ���� �� ����� ����������� � ����� ��������
         else
            {
            if ((newstop<OrderStopLoss()) && (newstop<OrderOpenPrice()) && (newstop>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            if (!OrderModify(ticket,OrderOpenPrice(),newstop,OrderTakeProfit(),OrderExpiration()))
            Print("�� ������� �������������� ����� �",OrderTicket(),". ������: ",GetLastError());
            }
         }
      }      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� RATCHET �����������                                     |
//| ��� ���������� �������� ������ 1 �������� - � +1, ��� ���������� |
//| �������� ������ 2 ������� - �������� - �� ������� 1, �����       |
//| ������ ��������� ������ 3 �������, �������� - �� ������� 2       |
//| (������ ����� �������� ������� ��������)                         |
//| ��� ������ � �������� ������� - ���� 3 ������, �� ����� ������   |
//| � ���� ��������� ����, � ������: ���� �� ���������� ���� ������, |
//| � ����� ��������� ���� ���� (������ ��� �������), �� ��������    |
//| ������ �� ���������, ����� �������� ������� (��������, ������    |
//| -5, -10 � -25, �������� -40; ���� ���������� ���� -10, � �����   |
//| ��������� ���� -10, �� �������� - �� -25, ���� ���������� ����   |
//| -5, �� �������� ��������� �� -10, ��� -2 (�����) ���� �� -5      |
//| �������� ������ � ����� �������� ������������                    |
//+------------------------------------------------------------------+
void TrailingRatchetB(int ticket,int pf_level_1,int pf_level_2,int pf_level_3,int ls_level_1,int ls_level_2,int ls_level_3,bool trlinloss)
   {
    
   // ��������� ���������� ��������
   if ((ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET)) || (pf_level_2<=pf_level_1) || (pf_level_3<=pf_level_2) || 
   (pf_level_3<=pf_level_1) || (pf_level_2-pf_level_1<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) || (pf_level_3-pf_level_2<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point) ||
   (pf_level_1<=MarketInfo(Symbol(),MODE_STOPLEVEL)))
      {
      Print("�������� �������� TrailingRatchetB() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      }
                
   // ���� ������� ������� (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      double dBid = MarketInfo(Symbol(),MODE_BID);
      
      // �������� �� ������� ��������
      
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_3+�����", �������� ��������� � "pf_level_2+�����"
      if ((dBid-OrderOpenPrice())>=pf_level_3*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + pf_level_2 *Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + pf_level_2*Point,OrderTakeProfit(),OrderExpiration());
         }
      else
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_2+�����", �������� ��������� � "pf_level_1+�����"
      if ((dBid-OrderOpenPrice())>=pf_level_2*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + pf_level_1*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + pf_level_1*Point,OrderTakeProfit(),OrderExpiration());
         }
      else        
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_1+�����", �������� ��������� � +1 ("�������� + �����")
      if ((dBid-OrderOpenPrice())>=pf_level_1*Point)
      // ���� �������� �� ��������� ��� ���� ��� "��������+1"
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()<OrderOpenPrice() + 1*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + 1*Point,OrderTakeProfit(),OrderExpiration());
         }

      // �������� �� ������� ������
      if (trlinloss==true)      
         {
         // ���������� ���������� ��������� �������� �������� ������ ������ ������ (ls_level_n), ���� �������� ��������� ����
         // (���� �� ����� ����� ����������� ����, ������������� �������� �� ��������� ����� �������� ������ ������ (���� ��� �� ��������� �������� �������)
         // ������ ���������� ���������� (���� ���)
         if(!GlobalVariableCheck("zeticket")) 
            {
            GlobalVariableSet("zeticket",ticket);
            // ��� �������� �������� �� "0"
            GlobalVariableSet("dpstlslvl",0);
            }
         // ���� �������� � ����� ������� (����� �����), �������� �������� dpstlslvl
         if (GlobalVariableGet("zeticket")!=ticket)
            {
            GlobalVariableSet("dpstlslvl",0);
            GlobalVariableSet("zeticket",ticket);
            }
      
         // ��������� ������� ������� ���� ����� �������� � �� ������� ������ �������
         if ((dBid-OrderOpenPrice())<pf_level_1*Point)         
            {
            // ���� (�������_���� �����/����� ��������) � (dpstlslvl>=ls_level_1), �������� - �� ls_level_1
            if (dBid>=OrderOpenPrice()) 
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_1*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_1*Point,OrderTakeProfit(),OrderExpiration());
      
            // ���� (�������_���� ����� ������_������_1) � (dpstlslvl>=ls_level_1), �������� - �� ls_level_2
            if ((dBid>=OrderOpenPrice()-ls_level_1*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_1))
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_2*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_2*Point,OrderTakeProfit(),OrderExpiration());
      
            // ���� (�������_���� ����� ������_������_2) � (dpstlslvl>=ls_level_2), �������� - �� ls_level_3
            if ((dBid>=OrderOpenPrice()-ls_level_2*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_2))
            if ((OrderStopLoss()==0) || (OrderStopLoss()<(OrderOpenPrice()-ls_level_3*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice()-ls_level_3*Point,OrderTakeProfit(),OrderExpiration());
      
            // ��������/������� �������� �������� �������� "������" �������� "���������"
            // ���� "�������_����-���� ��������+�����" ������ 0, 
            if ((dBid-OrderOpenPrice()+MarketInfo(Symbol(),MODE_SPREAD)*Point)<0)
            // ��������, �� ������ �� �� ���� ��� ����� ������ ������
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
      
   // ���� �������� ������� (OP_SELL)
   if (OrderType()==OP_SELL)
      {
      double dAsk = MarketInfo(Symbol(),MODE_ASK);
      
      // �������� �� ������� ��������
      
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_3+�����", �������� ��������� � "pf_level_2+�����"
      if ((OrderOpenPrice()-dAsk)>=pf_level_3*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (pf_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (pf_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }
      else
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_2+�����", �������� ��������� � "pf_level_1+�����"
      if ((OrderOpenPrice()-dAsk)>=pf_level_2*Point)
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (pf_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (pf_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }
      else        
      // ���� ������� "�������_����-����_��������" ������ ��� "pf_level_1+�����", �������� ��������� � +1 ("�������� + �����")
      if ((OrderOpenPrice()-dAsk)>=pf_level_1*Point)
      // ���� �������� �� ��������� ��� ���� ��� "��������+1"
         {
         if ((OrderStopLoss()==0) || (OrderStopLoss()>OrderOpenPrice() - (1 + MarketInfo(Symbol(),MODE_SPREAD))*Point))
         OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() - (1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
         }

      // �������� �� ������� ������
      if (trlinloss==true)      
         {
         // ���������� ���������� ��������� �������� �������� ������ ������ ������ (ls_level_n), ���� �������� ��������� ����
         // (���� �� ����� ����� ����������� ����, ������������� �������� �� ��������� ����� �������� ������ ������ (���� ��� �� ��������� �������� �������)
         // ������ ���������� ���������� (���� ���)
         if(!GlobalVariableCheck("zeticket")) 
            {
            GlobalVariableSet("zeticket",ticket);
            // ��� �������� �������� �� "0"
            GlobalVariableSet("dpstlslvl",0);
            }
         // ���� �������� � ����� ������� (����� �����), �������� �������� dpstlslvl
         if (GlobalVariableGet("zeticket")!=ticket)
            {
            GlobalVariableSet("dpstlslvl",0);
            GlobalVariableSet("zeticket",ticket);
            }
      
         // ��������� ������� ������� ���� ����� �������� � �� ������� ������ �������
         if ((OrderOpenPrice()-dAsk)<pf_level_1*Point)         
            {
            // ���� (�������_���� �����/����� ��������) � (dpstlslvl>=ls_level_1), �������� - �� ls_level_1
            if (dAsk<=OrderOpenPrice()) 
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // ���� (�������_���� ����� ������_������_1) � (dpstlslvl>=ls_level_1), �������� - �� ls_level_2
            if ((dAsk<=OrderOpenPrice() + (ls_level_1 + MarketInfo(Symbol(),MODE_SPREAD))*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_1))
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // ���� (�������_���� ����� ������_������_2) � (dpstlslvl>=ls_level_2), �������� - �� ls_level_3
            if ((dAsk<=OrderOpenPrice() + (ls_level_2 + MarketInfo(Symbol(),MODE_SPREAD))*Point) && (GlobalVariableGet("dpstlslvl")>=ls_level_2))
            if ((OrderStopLoss()==0) || (OrderStopLoss()>(OrderOpenPrice() + (ls_level_3 + MarketInfo(Symbol(),MODE_SPREAD))*Point)))
            OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice() + (ls_level_3 + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      
            // ��������/������� �������� �������� �������� "������" �������� "���������"
            // ���� "�������_����-���� ��������+�����" ������ 0, 
            if ((OrderOpenPrice()-dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)<0)
            // ��������, �� ������ �� �� ���� ��� ����� ������ ������
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
//| �������� �� ������� ������                                       |
//| ������� ��������� ����� �������, ������ (���-�� �����) ���      | 
//| �������� ������� � ������ ������ ������, ������ (�������), ��    |
//| ������� ����������� �������� �� ������� ������                   |
//| �������� �� ����������� �����.                                   |
//+------------------------------------------------------------------+
void TrailingByPriceChannel(int iTicket,int iBars_n,int iIndent)
   {     
   
   // ��������� ���������� ��������
   if ((iBars_n<1) || (iIndent<0) || (iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)))
      {
      Print("�������� �������� TrailingByPriceChannel() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 
   
   double   dChnl_max; // ������� ������� ������
   double   dChnl_min; // ������ ������� ������
   
   // ���������� ����.��� � ���.��� �� iBars_n ����� ������� � [1] (= ������� � ������ ������� �������� ������)
   dChnl_max = High[iHighest(Symbol(),0,2,iBars_n,1)] + (iIndent+MarketInfo(Symbol(),MODE_SPREAD))*Point;
   dChnl_min = Low[iLowest(Symbol(),0,1,iBars_n,1)] - iIndent*Point;   
   
   // ���� ������� �������, � � �������� ���� (���� ������ ������� ������ ���� �� ���������, ==0), ������������ ���
   if (OrderType()==OP_BUY)
      {
      if ((OrderStopLoss()<dChnl_min) && (dChnl_min<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dChnl_min,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
   
   // ���� ������� - ��������, � � �������� ���� (���� ������� ������� ������ ��� �� ��������, ==0), ������������ ���
   if (OrderType()==OP_SELL)
      {
      if (((OrderStopLoss()==0) || (OrderStopLoss()>dChnl_max)) && (dChnl_min>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dChnl_max,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� �� ����������� ��������                                 |
//| ������� ��������� ����� ������� � ��������� ������� (���������, | 
//| ������, ���, ����� ������������ �������, ����� �����������,      |
//| ������������ OHCL ��� ����������, � ����, �� ������� �������     |
//| �������� �������.                                                |
//+------------------------------------------------------------------+

//    ���������� �������� �����:   
//    iTmFrme:    1 (M1), 5 (M5), 15 (M15), 30 (M30), 60 (H1), 240 (H4), 1440 (D), 10080 (W), 43200 (MN);
//    iMAPeriod:  2-infinity, ����� �����; 
//    iMAShift:   ����� ������������� ��� ������������� �����, � ����� 0;
//    MAMethod:   0 (MODE_SMA), 1 (MODE_EMA), 2 (MODE_SMMA), 3 (MODE_LWMA);
//    iApplPrice: 0 (PRICE_CLOSE), 1 (PRICE_OPEN), 2 (PRICE_HIGH), 3 (PRICE_LOW), 4 (PRICE_MEDIAN), 5 (PRICE_TYPICAL), 6 (PRICE_WEIGHTED)
//    iShift:     0-Bars, ����� �����;
//    iIndent:    0-infinity, ����� �����;

void TrailingByMA(int iTicket,int iTmFrme,int iMAPeriod,int iMAShift,int MAMethod,int iApplPrice,int iShift,int iIndent)
   {     
   
   // ��������� ���������� ��������
   if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || ((iTmFrme!=1) && (iTmFrme!=5) && (iTmFrme!=15) && (iTmFrme!=30) && (iTmFrme!=60) && (iTmFrme!=240) && (iTmFrme!=1440) && (iTmFrme!=10080) && (iTmFrme!=43200)) ||
   (iMAPeriod<2) || (MAMethod<0) || (MAMethod>3) || (iApplPrice<0) || (iApplPrice>6) || (iShift<0) || (iIndent<0))
      {
      Print("�������� �������� TrailingByMA() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      } 

   double   dMA; // �������� ����������� �������� � ����������� �����������
   
   // ��������� �������� �� � ����������� ������� �����������
   dMA = iMA(Symbol(),iTmFrme,iMAPeriod,iMAShift,MAMethod,iApplPrice,iShift);
         
   // ���� ������� �������, � � �������� ���� �������� �������� � �������� � iIndent �������, ������������ ���
   if (OrderType()==OP_BUY)
      {
      if ((OrderStopLoss()<dMA-iIndent*Point) && (dMA-iIndent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dMA-iIndent*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
   
   // ���� ������� - ��������, � � �������� ���� (���� ������� ������� ������ ��� �� ��������, ==0), ������������ ���
   if (OrderType()==OP_SELL)
      {
      if (((OrderStopLoss()==0) || (OrderStopLoss()>dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point)) && (dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         {
         if (!OrderModify(iTicket,OrderOpenPrice(),dMA+(MarketInfo(Symbol(),MODE_SPREAD)+iIndent)*Point,OrderTakeProfit(),OrderExpiration()))
         Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
         }
      }
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� "�����������"                                           |
//| �� �������� ���������� ������� (����) ����������� �������� ��    |
//| �������� (�� ����� � ����� ���� �����������) ���������, ����-    |
//| ������ ������ (�.�., ��������, �� �������� ����� ������ +55 �. - |
//| �������� ��������� � 55/2=27 �. ���� �� �������� ����.           |
//| ����� ������ ������, ��������, +80 �., �� �������� ��������� ��  |
//| �������� (����.) ���������� ����� ���. ���������� � ������ ��    |
//| �������� ���� - 27 + (80-27)/2 = 27 + 53/2 = 27 + 26 = 53 �.     |
//| iTicket - ����� �������; iTmFrme - ��������� (� �������, ������� |
//| dCoeff - "����������� ��������", � % �� 0.01 �� 1 (� ���������   |
//| ������ �������� ����� ��������� (���� ���������) �������� � ���. |
//| ����� � �������, ������ �����, ����� �� ���������)               |
//| bTrlinloss - ����� �� ������� �� �������� ������� - ���� ��, ��  |
//| �� �������� ���������� ���� ���������� ����� ���������� (� �.�.  |
//| "��" ���������) � ������� ������ ����� ����������� � dCoeff ���  |
//| ����� ����. ������� �������, ����������� ������ ���� ��������   |
//| �������� (�� ����� 0)                                            |
//+------------------------------------------------------------------+

void TrailingFiftyFifty(int iTicket,int iTmFrme,double dCoeff,bool bTrlinloss)
   { 
   // ���������� �������� ������ �� �������� ����
   if (sdtPrevtime == iTime(Symbol(),iTmFrme,0)) return(0);
   else
      {
      sdtPrevtime = iTime(Symbol(),iTmFrme,0);             
      
      // ��������� ���������� ��������
      if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || 
      ((iTmFrme!=1) && (iTmFrme!=5) && (iTmFrme!=15) && (iTmFrme!=30) && (iTmFrme!=60) && (iTmFrme!=240) && 
      (iTmFrme!=1440) && (iTmFrme!=10080) && (iTmFrme!=43200)) || (dCoeff<0.01) || (dCoeff>1.0))
         {
         Print("�������� �������� TrailingFiftyFifty() ���������� ��-�� �������������� �������� ���������� �� ����������.");
         return(0);
         }
         
      // �������� ������� - � ������� ���� ����� ������������ (����� ��� bTrlinloss ����� �� ����� �������� 
      // ������� �������� ����� ��������� �� �������� ���������� ����� ���������� � ������ ��������)
      // �.�. �������� ������ ��� �������, ��� � ������� OrderOpenTime() ������ �� ����� iTmFrme �����
      if (iTime(Symbol(),iTmFrme,0)>OrderOpenTime())
      {         
      
      double dBid = MarketInfo(Symbol(),MODE_BID);
      double dAsk = MarketInfo(Symbol(),MODE_ASK);
      double dNewSl;
      double dNexMove;     
      
      // ��� ������� ������� ��������� �������� �� dCoeff ��������� �� ����� �������� �� Bid �� ������ �������� ����
      // (���� ����� �������� ����� ���������� � �������� �������� � ������� �������)
      if (OrderType()==OP_BUY)
         {
         if ((bTrlinloss) && (OrderStopLoss()!=0))
            {
            dNexMove = NormalizeDouble(dCoeff*(dBid-OrderStopLoss()),Digits);
            dNewSl = NormalizeDouble(OrderStopLoss()+dNexMove,Digits);            
            }
         else
            {
            // ���� �������� ���� ����� ��������, �� ������ "�� ����� ��������"
            if (OrderOpenPrice()>OrderStopLoss())
               {
               dNexMove = NormalizeDouble(dCoeff*(dBid-OrderOpenPrice()),Digits);                 
               //Print("dNexMove = ",dCoeff,"*(",dBid,"-",OrderOpenPrice(),")");
               dNewSl = NormalizeDouble(OrderOpenPrice()+dNexMove,Digits);
               //Print("dNewSl = ",OrderOpenPrice(),"+",dNexMove);
               }
         
            // ���� �������� ���� ����� ��������, ������ �� ���������
            if (OrderStopLoss()>=OrderOpenPrice())
               {
               dNexMove = NormalizeDouble(dCoeff*(dBid-OrderStopLoss()),Digits);
               dNewSl = NormalizeDouble(OrderStopLoss()+dNexMove,Digits);
               }                                      
            }
            
         // �������� ���������� ������ � ������, ���� ����� �������� ����� �������� � ���� �������� - � ������� �������
         // (��� ������ ��������, �� ����� ��������, ����� �������� ����� ���� ����� ����������, � � �� �� ����� ���� 
         // ����� �������� (���� dBid ���� ����������) 
         if ((dNewSl>OrderStopLoss()) && (dNexMove>0) && ((dNewSl<Bid- MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)))
            {
            if (!OrderModify(OrderTicket(),OrderOpenPrice(),dNewSl,OrderTakeProfit(),OrderExpiration(),Red))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }       
      
      // �������� ��� �������� �������   
      if (OrderType()==OP_SELL)
         {
         if ((bTrlinloss) && (OrderStopLoss()!=0))
            {
            dNexMove = NormalizeDouble(dCoeff*(OrderStopLoss()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);
            dNewSl = NormalizeDouble(OrderStopLoss()-dNexMove,Digits);            
            }
         else
            {         
            // ���� �������� ���� ����� ��������, �� ������ "�� ����� ��������"
            if (OrderOpenPrice()<OrderStopLoss())
               {
               dNexMove = NormalizeDouble(dCoeff*(OrderOpenPrice()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);                 
               dNewSl = NormalizeDouble(OrderOpenPrice()-dNexMove,Digits);
               }
         
            // ���� �������� ���� ����� ��������, ������ �� ���������
            if (OrderStopLoss()<=OrderOpenPrice())
               {
               dNexMove = NormalizeDouble(dCoeff*(OrderStopLoss()-(dAsk+MarketInfo(Symbol(),MODE_SPREAD)*Point)),Digits);
               dNewSl = NormalizeDouble(OrderStopLoss()-dNexMove,Digits);
               }                  
            }
         
         // �������� ���������� ������ � ������, ���� ����� �������� ����� �������� � ���� �������� - � ������� �������
         if ((dNewSl<OrderStopLoss()) && (dNexMove>0) && (dNewSl>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
            {
            if (!OrderModify(OrderTicket(),OrderOpenPrice(),dNewSl,OrderTakeProfit(),OrderExpiration(),Blue))
            Print("�� ������� �������������� �������� ������ �",OrderTicket(),". ������: ",GetLastError());
            }
         }               
      }
      }   
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| �������� KillLoss                                                |
//| ����������� �� ������� ������. ����: �������� �������� ��������� |
//| ����� �� ��������� �������� ����� � ����������� (dSpeedCoeff).   |
//| ��� ���� ����������� ����� "���������" � �������� ����������     |
//| ������ - ���, ����� ��� ������� ����� ����� �������� ������. ��� |
//| ������������ = 1 �������� ��������� ����� ��������� ����� ����-  |
//| ��� ��������� � ������ �� ������ ������� �������, ��� �����.>1   |
//| ����� ������� ����� � ��������� ����� ������� � ������� �����-   |
//| ���� ��������� �����, ��� �����.<1 - ��������, ����� � �������-  |
//| �� ���������.                                                    |
//+------------------------------------------------------------------+

void KillLoss(int iTicket,double dSpeedCoeff)
   {   
   // ��������� ���������� ��������
   if ((iTicket==0) || (!OrderSelect(iTicket,SELECT_BY_TICKET)) || (dSpeedCoeff<0.1))
      {
      Print("�������� �������� KillLoss() ���������� ��-�� �������������� �������� ���������� �� ����������.");
      return(0);
      }           
      
   double dStopPriceDiff; // ���������� (�������) ����� ������ � ����������   
   double dToMove; // ���-�� �������, �� ������� ������� ����������� ��������   
   // ������� ����
   double dBid = MarketInfo(OrderSymbol(),MODE_BID);
   double dAsk = MarketInfo(OrderSymbol(),MODE_ASK);      
   
   // ������� ���������� ����� ������ � ����������
   if (OrderType()==OP_BUY) dStopPriceDiff = dBid - OrderStopLoss();
   if (OrderType()==OP_SELL) dStopPriceDiff = (OrderStopLoss() + MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT)) - dAsk;                  
   
   // ���������, ���� ����� != ������, � ������� �������� ������, ���������� ������� ���������� ����� ������ � ����������
   if (GlobalVariableGet("zeticket")!=iTicket)
      {
      GlobalVariableSet("sldiff",dStopPriceDiff);      
      GlobalVariableSet("zeticket",iTicket);
      }
   else
      {                                   
      // ����, � ��� ���� ����������� ��������� ��������� �����
      // �� ������ �����, ������� �������� ���� � ������� �����, 
      // �� ������ ����������� �������� ��� �� ������� �� dSpeedCoeff ��� �������
      // (��������, ���� ���� ���������� �� 3 ������ �� ���, dSpeedCoeff = 1.5, ��
      // �������� ����������� �� 3 � 1.5 = 4.5, ��������� - 5 �. ���� ��������� �� 
      // ������ (������� ������), ������ �� ������.            
      
      // ���-�� �������, �� ������� ����������� ���� � ��������� � ������� ���������� �������� (����, �� ����)
      dToMove = (GlobalVariableGet("sldiff") - dStopPriceDiff) / MarketInfo(OrderSymbol(),MODE_POINT);
      
      // ���������� ����� ��������, �� ������ ���� ��� �����������
      if (dStopPriceDiff<GlobalVariableGet("sldiff"))
      GlobalVariableSet("sldiff",dStopPriceDiff);
      
      // ������ �������� �� ������, ���� ���������� ����������� (�.�. ���� ����������� � ���������, ������ ������)
      if (dToMove>0)
         {       
         // ��������, ��������������, ����� ����� ����������� �� ����� �� ����������, �� � ������ �����. ���������
         dToMove = MathRound(dToMove * dSpeedCoeff) * MarketInfo(OrderSymbol(),MODE_POINT);                 
      
         // ������ ��������, ����� �� �� ��������� �������� �� ����� ����������
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