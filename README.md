## Linki
Moduł:
https://pl.wikipedia.org/w/index.php?title=Modu%C5%82:ISBN&action=edit

Główny szablon:
https://pl.wikipedia.org/w/index.php?title=Szablon:ISBN&action=edit
`{{#invoke:ISBN|link}}`

Ale również:
- `{{#invoke:ISBN|link|{{{isbn}}}}}` https://pl.wikipedia.org/wiki/Szablon:Cytuj_ksi%C4%85%C5%BCk%C4%99
- `require("Moduł:ISBN").link(builder, v)` https://pl.wikipedia.org/wiki/Modu%C5%82:Cytuj

## TODO
- [x] Dostosowanie pod testowanie i pod [wiki-lua-mw-mock](https://github.com/Eccenux/wiki-lua-mw-mock)
- [x] Test na generującym link `9788388147159`
	Linkujące: https://pl.wikipedia.org/wiki/Specjalna:Linkuj%C4%85ce/Modu%C5%82:ISBN/9788388147159
	Przykład:
	Systematyka i nazwy polskie za: Włodzimierz Cichocki, Agnieszka Ważna, Jan Cichocki, Ewa Rajska, Artur Jasiński, Wiesław Bogdanowicz: Polskie nazewnictwo ssaków świata. Warszawa: Muzeum i Instytut Zoologii PAN, 2015, s. 151. ISBN 978-83-88147-15-9.
	- [x] ISBN poprawny? -> TAK 🤔 
	- [x] ISBN poprawny wg modułu? -> Tak, ale on zawsze próbuje pobrać uzasadnienie...
	--> To tworzy wpis w linkujących (połączenie nazwy modułu i oczyszczonego ISBN):
	`mw.title.new(resources.findLinkPrefix..clean).exists`
- [ ] Zamienić ładowanie podstron na jeden lub kilka ładowanych plików.
	Badanie exist jest wolne (kosztowne).
	Dodatkowo te podstrony są trochę zbyt magiczne (nie ma nawet dokumentacji co należy dodać na tych podstronach).
	[XOR] Najlepiej z punktu widzenia użytkowników pewnie byłoby mieć JSON (łatwiejszy do edycji i podglądu... trochę?...).
	[XOR] Łatwiej z punktu widzenia Lua byłoby ładować dane z Lua. No i w Lua jednak można komentarze dodać...🤔

	Research:
	- [x] Spr. autorów i ew. daty. Ktoś dodawał te podstrony poza PZ? Ktoś dodawał je niedawno?
		-> czasem ktoś coś dodaje, ale rzadko.
		-> większość jednak dodał PZ 2016-12-08.
	- [x] Pobrać kod podstron.
		(Side note: dokumentacja tych podstron generuje się automatycznie) 
	- [x] Ile stron linkuje do nieprawidłowych? Skasować część zbędnych? Jak numer ma złą liczbę cyfr, to taka podstrona ma sens? -> podstrona jest tylko informacją, że numer jest prawidłowo wpisany (nieprawidłowy, ale gdzieś potwierdzony).

	Budowanie nowej listy:
	- [x] Zbudować listę z meta i pobranych plików.
	- [x] Komentarz z podstron dodać do info o błędzie? -> tylko jako komentarz w pliku za sugestią PZ
	- [x] Podmiana `justified` na spr. tabeli.
	- [x] Wyrzucenie pcall z opis (nieużywane w praktyce).
	- [ ] Raportowanie błędnych numerów w kategorii?
		categoryIncorrectNumber
		categoryInvalidNumber
- [ ] Sprzątanie
	- [ ] Skasować podstrony numeryczne.
	- [ ] Wywalić magiczną generację dokumentacji podstron ISBN? Gdzie to jest?