/*.
Этот учебник построен на основе задач, рассмотренных в учебнике Завершение диалога между базами данных. 
В настоящем учебнике показан порядок настройки диалога для запуска его между двумя экземплярами компонента 
Database Engine.

В нем используются практически те же шаги, что в учебнике «Завершение диалога между двумя базами данных», 
за исключением следующих моментов.
    >Обе базы данных размещены в разных экземплярах компонента Database Engine.
    >Показано, как создавать конечные точки компонента Service Broker и маршруты 
	для установления сетевых подключений между двумя экземплярами.
    >В предыдущих учебниках передача сообщений по сети не рассматривалась. Поэтому 
	для обеспечения защиты сообщений от несанкционированного доступа в них использовались 
	разрешения компонента Database Engine. На занятии 3 показано, как создавать сертификаты 
	и привязки удаленных служб для шифрования сетевых сообщений. 

В этом учебнике экземпляр компонента Database Engine, содержащий базу данных инициатора, называется «экземпляром инициатора». 
Экземпляр, содержащий целевую базу данных, называется «целевым экземпляром».

Учебник состоит из шести занятий.

Занятие 1. Создание целевой базы данных
    На этом занятии создается целевая база данных и все объекты, не имеющие зависимостей в базе данных инициатора: 
	конечная точка, главный ключ, сертификат, пользователи, типы сообщений, контракт, служба и очередь.

Занятие 2. Создание инициирующей базы данных
    На этом занятии создается база данных инициатора и ее конечная точка, главный ключ, сертификат, пользователи, 
	маршруты, привязки удаленных служб, типы сообщений, контракт, служба и очередь.

Занятие 3. Завершение объектов целевой стороны диалога
    На этом занятии создаются целевые объекты, имеющие зависимости в базе данных инициатора: сертификаты, пользователи, 
	маршруты и привязки удаленных служб.

Занятие 4. Начало диалога
    На этом занятии рассматривается запуск диалога и отправка сообщения запроса с экземпляра инициатора на целевой экземпляр.

Занятие 5. Получение запроса и отправка ответа
    На этом занятии целевая служба получает сообщение запроса и отправляет ответное сообщение инициатору.

Занятие 6. Получение ответа и завершение диалога
    На этом занятии вызывающая служба получает ответное сообщение и завершает диалог.
*/