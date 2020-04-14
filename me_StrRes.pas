unit me_StrRes;

interface

resourcestring
  rsQuit                = 'Действительно выйти из MyEngine?';
  rsFirstRun            = 'Добро пожаловать!'#13#10+
                          'Настройте программу перед использованием.';

  // Статус программы
  rsNotConnected        = 'Не подключен';
  rsReadingPort         = 'Идет считывание';
  rsOpenPortError       = 'Ошибка открытия порта "%s"';
  rsCOMPortIsClose      = 'COM-порт закрыт';
  rsCOMPortIsOpen       = 'COM-порт открыт';

  // ********* Значения параметров маршрутного компьютера
  rsOn                  = 'Вкл';
  rsOff                 = 'Откл';

  rsYes                 = 'Да';
  rsNo                  = 'Нет';

  rsHave                = 'Есть';
  rsHaveNot             = 'Нет';

  rsOpen                = 'Откр';
  rsClose               = 'Закр';

  rsMixRich             = 'Бог';
  rsMixLean             = 'Бедн';

  // ********* Названия параметров маршрутного компьютера
  rsAvrgFuelChargeBy100km               = 'Средний расход';
  rsFuelChargeNowBy100km                = 'Мгновенный расход';
  rsAvrgFuelChargeByHour                = 'Средний расход';
  rsFuelChargeNowByHour               = 'Мгновенный расход';
  rsFuelCharge                = 'Израсходованно';
  rsFuelTank                = 'Бензобак';
  rsToStop                = 'До остановки';
  rsFuelEconomy               = 'Сэкономлено';

  rs_08_Speed               = 'Скорость';
  rsAvrgSpeed               = 'Средняя скорость';
  rsMaxSpeed                = 'Макс. скорость';

  rsAllTime               = 'Общее время';
  rsDriveTime               = 'Время движения';
  rsStayTime                = 'Время остановок';
  rsLiveDist                = 'Текущий пробег';

  rsODO               = 'Общий пробег';
  rsODO_A               = 'Пробег А';
  rsODO_B               = 'Пробег Б';

  rs_01_Injector                = 'Форсунки';
  rs_02_Ignition                = 'Зажигание';
  rs_03_ValveXX               = 'Клапан ХХ';
  rs_04_RPM               = 'Обороты';

  rs_05_AirFlowMAP               = 'MAP';
  rs_05_AirFlowMAF               = 'MAF';
  rs_05_AirFlowVAF               = 'VAF';

  rs_06_Temperature               = 'Температура';
  rs_07_ThrottleBody                = 'БДЗ';
  rs_09_CorrectionL               = 'Коррекция Л.';
  rs_10_CorrectionR               = 'Коррекция Пр.';

  rs_11_0_ColdStart               = 'Переоб.посл.зап.';
  rs_11_1_ColdEngine                = 'Холод.двигатель';
  rs_11_2_Unknown               = '11.2 Unknown';
  rs_11_3_Unknown               = '11.3 Unknown';
  rs_11_4_Knock               = 'Детонация';
  rs_11_5_Feedback                = '11.5 Впрыск';
  rs_11_6_Enrichment                = 'Доп.обогащение';
  rs_11_7_Unknown               = '11.7 Unknown';

  rs_12_0_Starter               = 'Стартер';
  rs_12_1_Throttle                = 'Дрос. заслонка';
  rs_12_2_AirCond               = 'Кондиционер';
  rs_12_3_Neutral               = 'Нейтраль';
  rs_12_4_MixL                = 'Смесь Левая';
  rs_12_5_MixR                = 'Смесь Правая';
  rs_12_6_Unknown               = '12.6 Unknown';
  rs_12_7_Unknown               = '12.7 Двигались?';

  // ********* Названия едениц измерения параметров маршрутного компьютера
  rsLitersOn100km   = 'л/100км';
  rsLitersOnH       = 'л/час';
  rsLiters          = 'л';
  rsKm              = 'км';
  rsKmH             = 'км/ч';
  rsMs              = 'мс';
  rsGrad            = 'град';
  rsStep            = 'шаг';
  rsProc            = '%';
  rsRPM             = 'об/м';
  rsVolts           = 'В';
  rs_kPa            = 'кПа';
  rs_mmRtSt         = 'мм.рт.ст.';
  rs_GrSec          = 'гр/сек';
  rsTemp            = '°C';

  // ********* Названия полей окна пробега

  // ********* Названия полей круиз дисплея  
  

implementation

end.
