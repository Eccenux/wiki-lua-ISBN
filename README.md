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
- [ ] Test na generującym link `9788388147159`
	Linkujące: https://pl.wikipedia.org/wiki/Specjalna:Linkuj%C4%85ce/Modu%C5%82:ISBN/9788388147159
	Przykład:
	Systematyka i nazwy polskie za: Włodzimierz Cichocki, Agnieszka Ważna, Jan Cichocki, Ewa Rajska, Artur Jasiński, Wiesław Bogdanowicz: Polskie nazewnictwo ssaków świata. Warszawa: Muzeum i Instytut Zoologii PAN, 2015, s. 151. ISBN 978-83-88147-15-9.
	- [x] ISBN poprawny? -> TAK 🤔 
	- [ ] ISBN poprawny wg modułu?
- [ ] 