# Community_iKnow
## Установка
1. Скачать и импортировать классы в нужную область.
2. В данной области, в веб-приложении по умолчанию, поставить галочку iKnow.
3. Открыть класс `Community.iKnow.Utils`. В параметрах `SetsFileLocation` и `BLFileLocation` нужно указать существующие пути к Sets и Черному списку
4. Перейти в терминал и запустить метод `do ##class(Community.iKnow.Utils).setup()`.
Этот метод создаст домейн, добавит в него все элементы из черного списка и все Sets. 

## Возможности
### Класс Post
- `set result = ##class(Community.iKnow.Post).GetConceptsByID(ID)` - Метод возвращает все концепты по ID поста.
- `set result = ##class(Community.iKnow.Post).GetSetsByID(ID)` - Метод возвращает все sets по ID поста.
- `set result = ##class(Community.iKnow.Post).GetSetsAndConceptsByID(ID)` - Метод возвращает объединенные Sets и концепты по ID поста.
### Класс Answer
- `set result = ##class(Community.iKnow.Answer).GetConceptsByID(ID)` - Метод возвращает все концепты по ID ответа.
- `set result = ##class(Community.iKnow.Answer).GetSetsByID(ID)` - Метод возвращает все sets по ID ответам.
- `set result = ##class(Community.iKnow.Answer).GetSetsAndConceptsByID(ID)` - Метод возвращает объединенные Sets и концепты по ID ответа.
### Класс Utils
