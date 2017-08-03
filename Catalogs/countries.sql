declare @country xml = '
<country-list>
<country>
<name>Абхазия</name>
<fullname>Республика Абхазия</fullname>
<english>Abkhazia</english>
<alpha2>AB</alpha2>
<alpha3>ABH</alpha3>
<iso>895</iso>
<location>Азия</location>
<location-precise>Закавказье</location-precise>
</country>
<country>
<name>Австралия</name>
<fullname></fullname>
<english>Australia</english>
<alpha2>AU</alpha2>
<alpha3>AUS</alpha3>
<iso>036</iso>
<location>Океания</location>
<location-precise>Австралия и Новая Зеландия</location-precise>
</country>
<country>
<name>Австрия</name>
<fullname>Австрийская Республика</fullname>
<english>Austria</english>
<alpha2>AT</alpha2>
<alpha3>AUT</alpha3>
<iso>040</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Азербайджан</name>
<fullname>Республика Азербайджан</fullname>
<english>Azerbaijan</english>
<alpha2>AZ</alpha2>
<alpha3>AZE</alpha3>
<iso>031</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Албания</name>
<fullname>Республика Албания</fullname>
<english>Albania</english>
<alpha2>AL</alpha2>
<alpha3>ALB</alpha3>
<iso>008</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Алжир</name>
<fullname>Алжирская Народная Демократическая Республика</fullname>
<english>Algeria</english>
<alpha2>DZ</alpha2>
<alpha3>DZA</alpha3>
<iso>012</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Американское Самоа</name>
<fullname></fullname>
<english>American Samoa</english>
<alpha2>AS</alpha2>
<alpha3>ASM</alpha3>
<iso>016</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Ангилья</name>
<fullname></fullname>
<english>Anguilla</english>
<alpha2>AI</alpha2>
<alpha3>AIA</alpha3>
<iso>660</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Ангола</name>
<fullname>Республика Ангола</fullname>
<english>Angola</english>
<alpha2>AO</alpha2>
<alpha3>AGO</alpha3>
<iso>024</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Андорра</name>
<fullname>Княжество Андорра</fullname>
<english>Andorra</english>
<alpha2>AD</alpha2>
<alpha3>AND</alpha3>
<iso>020</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Антарктида</name>
<fullname></fullname>
<english>Antarctica</english>
<alpha2>AQ</alpha2>
<alpha3>ATA</alpha3>
<iso>010</iso>
<location>Антарктика</location>
<location-precise></location-precise>
</country>
<country>
<name>Антигуа и Барбуда</name>
<fullname></fullname>
<english>Antigua and Barbuda</english>
<alpha2>AG</alpha2>
<alpha3>ATG</alpha3>
<iso>028</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Аргентина</name>
<fullname>Аргентинская Республика</fullname>
<english>Argentina</english>
<alpha2>AR</alpha2>
<alpha3>ARG</alpha3>
<iso>032</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Армения</name>
<fullname>Республика Армения</fullname>
<english>Armenia</english>
<alpha2>AM</alpha2>
<alpha3>ARM</alpha3>
<iso>051</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Аруба</name>
<fullname></fullname>
<english>Aruba</english>
<alpha2>AW</alpha2>
<alpha3>ABW</alpha3>
<iso>533</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Афганистан</name>
<fullname>Переходное Исламское Государство Афганистан</fullname>
<english>Afghanistan</english>
<alpha2>AF</alpha2>
<alpha3>AFG</alpha3>
<iso>004</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Багамы</name>
<fullname>Содружество Багамы</fullname>
<english>Bahamas</english>
<alpha2>BS</alpha2>
<alpha3>BHS</alpha3>
<iso>044</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Бангладеш</name>
<fullname>Народная Республика Бангладеш</fullname>
<english>Bangladesh</english>
<alpha2>BD</alpha2>
<alpha3>BGD</alpha3>
<iso>050</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Барбадос</name>
<fullname></fullname>
<english>Barbados</english>
<alpha2>BB</alpha2>
<alpha3>BRB</alpha3>
<iso>052</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Бахрейн</name>
<fullname>Королевство Бахрейн</fullname>
<english>Bahrain</english>
<alpha2>BH</alpha2>
<alpha3>BHR</alpha3>
<iso>048</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Беларусь</name>
<fullname>Республика Беларусь</fullname>
<english>Belarus</english>
<alpha2>BY</alpha2>
<alpha3>BLR</alpha3>
<iso>112</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Белиз</name>
<fullname></fullname>
<english>Belize</english>
<alpha2>BZ</alpha2>
<alpha3>BLZ</alpha3>
<iso>084</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Бельгия</name>
<fullname>Королевство Бельгии</fullname>
<english>Belgium</english>
<alpha2>BE</alpha2>
<alpha3>BEL</alpha3>
<iso>056</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Бенин</name>
<fullname>Республика Бенин</fullname>
<english>Benin</english>
<alpha2>BJ</alpha2>
<alpha3>BEN</alpha3>
<iso>204</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Бермуды</name>
<fullname></fullname>
<english>Bermuda</english>
<alpha2>BM</alpha2>
<alpha3>BMU</alpha3>
<iso>060</iso>
<location>Америка</location>
<location-precise>Северная Америка</location-precise>
</country>
<country>
<name>Болгария</name>
<fullname>Республика Болгария</fullname>
<english>Bulgaria</english>
<alpha2>BG</alpha2>
<alpha3>BGR</alpha3>
<iso>100</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Боливия, Многонациональное Государство</name>
<fullname>Многонациональное Государство Боливия</fullname>
<english>Bolivia, plurinational state of</english>
<alpha2>BO</alpha2>
<alpha3>BOL</alpha3>
<iso>068</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Бонайре, Саба и Синт-Эстатиус</name>
<fullname></fullname>
<english>Bonaire, Sint Eustatius and Saba</english>
<alpha2>BQ</alpha2>
<alpha3>BES</alpha3>
<iso>535</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Босния и Герцеговина</name>
<fullname></fullname>
<english>Bosnia and Herzegovina</english>
<alpha2>BA</alpha2>
<alpha3>BIH</alpha3>
<iso>070</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Ботсвана</name>
<fullname>Республика Ботсвана</fullname>
<english>Botswana</english>
<alpha2>BW</alpha2>
<alpha3>BWA</alpha3>
<iso>072</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Бразилия</name>
<fullname>Федеративная Республика Бразилия</fullname>
<english>Brazil</english>
<alpha2>BR</alpha2>
<alpha3>BRA</alpha3>
<iso>076</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Британская территория в Индийском океане</name>
<fullname></fullname>
<english>British Indian Ocean Territory</english>
<alpha2>IO</alpha2>
<alpha3>IOT</alpha3>
<iso>086</iso>
<location>Океания</location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Бруней-Даруссалам</name>
<fullname></fullname>
<english>Brunei Darussalam</english>
<alpha2>BN</alpha2>
<alpha3>BRN</alpha3>
<iso>096</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Буркина-Фасо</name>
<fullname></fullname>
<english>Burkina Faso</english>
<alpha2>BF</alpha2>
<alpha3>BFA</alpha3>
<iso>854</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Бурунди</name>
<fullname>Республика Бурунди</fullname>
<english>Burundi</english>
<alpha2>BI</alpha2>
<alpha3>BDI</alpha3>
<iso>108</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Бутан</name>
<fullname>Королевство Бутан</fullname>
<english>Bhutan</english>
<alpha2>BT</alpha2>
<alpha3>BTN</alpha3>
<iso>064</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Вануату</name>
<fullname>Республика Вануату</fullname>
<english>Vanuatu</english>
<alpha2>VU</alpha2>
<alpha3>VUT</alpha3>
<iso>548</iso>
<location>Океания</location>
<location-precise>Меланезия</location-precise>
</country>
<country>
<name>Венгрия</name>
<fullname>Венгерская Республика</fullname>
<english>Hungary</english>
<alpha2>HU</alpha2>
<alpha3>HUN</alpha3>
<iso>348</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Венесуэла Боливарианская Республика</name>
<fullname>Боливарийская Республика Венесуэла</fullname>
<english>Venezuela</english>
<alpha2>VE</alpha2>
<alpha3>VEN</alpha3>
<iso>862</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Виргинские острова, Британские</name>
<fullname>Британские Виргинские острова</fullname>
<english>Virgin Islands, British</english>
<alpha2>VG</alpha2>
<alpha3>VGB</alpha3>
<iso>092</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Виргинские острова, США</name>
<fullname>Виргинские острова Соединенных Штатов</fullname>
<english>Virgin Islands, U.S.</english>
<alpha2>VI</alpha2>
<alpha3>VIR</alpha3>
<iso>850</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Вьетнам</name>
<fullname>Социалистическая Республика Вьетнам</fullname>
<english>Vietnam</english>
<alpha2>VN</alpha2>
<alpha3>VNM</alpha3>
<iso>704</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Габон</name>
<fullname>Габонская Республика</fullname>
<english>Gabon</english>
<alpha2>GA</alpha2>
<alpha3>GAB</alpha3>
<iso>266</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Гаити</name>
<fullname>Республика Гаити</fullname>
<english>Haiti</english>
<alpha2>HT</alpha2>
<alpha3>HTI</alpha3>
<iso>332</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Гайана</name>
<fullname>Республика Гайана</fullname>
<english>Guyana</english>
<alpha2>GY</alpha2>
<alpha3>GUY</alpha3>
<iso>328</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Гамбия</name>
<fullname>Республика Гамбия</fullname>
<english>Gambia</english>
<alpha2>GM</alpha2>
<alpha3>GMB</alpha3>
<iso>270</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Гана</name>
<fullname>Республика Гана</fullname>
<english>Ghana</english>
<alpha2>GH</alpha2>
<alpha3>GHA</alpha3>
<iso>288</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Гваделупа</name>
<fullname></fullname>
<english>Guadeloupe</english>
<alpha2>GP</alpha2>
<alpha3>GLP</alpha3>
<iso>312</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Гватемала</name>
<fullname>Республика Гватемала</fullname>
<english>Guatemala</english>
<alpha2>GT</alpha2>
<alpha3>GTM</alpha3>
<iso>320</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Гвинея</name>
<fullname>Гвинейская Республика</fullname>
<english>Guinea</english>
<alpha2>GN</alpha2>
<alpha3>GIN</alpha3>
<iso>324</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Гвинея-Бисау</name>
<fullname>Республика Гвинея-Бисау</fullname>
<english>Guinea-Bissau</english>
<alpha2>GW</alpha2>
<alpha3>GNB</alpha3>
<iso>624</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Германия</name>
<fullname>Федеративная Республика Германия</fullname>
<english>Germany</english>
<alpha2>DE</alpha2>
<alpha3>DEU</alpha3>
<iso>276</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Гернси</name>
<fullname></fullname>
<english>Guernsey</english>
<alpha2>GG</alpha2>
<alpha3>GGY</alpha3>
<iso>831</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Гибралтар</name>
<fullname></fullname>
<english>Gibraltar</english>
<alpha2>GI</alpha2>
<alpha3>GIB</alpha3>
<iso>292</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Гондурас</name>
<fullname>Республика Гондурас</fullname>
<english>Honduras</english>
<alpha2>HN</alpha2>
<alpha3>HND</alpha3>
<iso>340</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Гонконг</name>
<fullname>
Специальный административный регион Китая Гонконг
</fullname>
<english>Hong Kong</english>
<alpha2>HK</alpha2>
<alpha3>HKG</alpha3>
<iso>344</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Гренада</name>
<fullname></fullname>
<english>Grenada</english>
<alpha2>GD</alpha2>
<alpha3>GRD</alpha3>
<iso>308</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Гренландия</name>
<fullname></fullname>
<english>Greenland</english>
<alpha2>GL</alpha2>
<alpha3>GRL</alpha3>
<iso>304</iso>
<location>Америка</location>
<location-precise>Северная Америка</location-precise>
</country>
<country>
<name>Греция</name>
<fullname>Греческая Республика</fullname>
<english>Greece</english>
<alpha2>GR</alpha2>
<alpha3>GRC</alpha3>
<iso>300</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Грузия</name>
<fullname></fullname>
<english>Georgia</english>
<alpha2>GE</alpha2>
<alpha3>GEO</alpha3>
<iso>268</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Гуам</name>
<fullname></fullname>
<english>Guam</english>
<alpha2>GU</alpha2>
<alpha3>GUM</alpha3>
<iso>316</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Дания</name>
<fullname>Королевство Дания</fullname>
<english>Denmark</english>
<alpha2>DK</alpha2>
<alpha3>DNK</alpha3>
<iso>208</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Джерси</name>
<fullname></fullname>
<english>Jersey</english>
<alpha2>JE</alpha2>
<alpha3>JEY</alpha3>
<iso>832</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Джибути</name>
<fullname>Республика Джибути</fullname>
<english>Djibouti</english>
<alpha2>DJ</alpha2>
<alpha3>DJI</alpha3>
<iso>262</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Доминика</name>
<fullname>Содружество Доминики</fullname>
<english>Dominica</english>
<alpha2>DM</alpha2>
<alpha3>DMA</alpha3>
<iso>212</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Доминиканская Республика</name>
<fullname></fullname>
<english>Dominican Republic</english>
<alpha2>DO</alpha2>
<alpha3>DOM</alpha3>
<iso>214</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Египет</name>
<fullname>Арабская Республика Египет</fullname>
<english>Egypt</english>
<alpha2>EG</alpha2>
<alpha3>EGY</alpha3>
<iso>818</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Замбия</name>
<fullname>Республика Замбия</fullname>
<english>Zambia</english>
<alpha2>ZM</alpha2>
<alpha3>ZMB</alpha3>
<iso>894</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Западная Сахара</name>
<fullname></fullname>
<english>Western Sahara</english>
<alpha2>EH</alpha2>
<alpha3>ESH</alpha3>
<iso>732</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Зимбабве</name>
<fullname>Республика Зимбабве</fullname>
<english>Zimbabwe</english>
<alpha2>ZW</alpha2>
<alpha3>ZWE</alpha3>
<iso>716</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Израиль</name>
<fullname>Государство Израиль</fullname>
<english>Israel</english>
<alpha2>IL</alpha2>
<alpha3>ISR</alpha3>
<iso>376</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Индия</name>
<fullname>Республика Индия</fullname>
<english>India</english>
<alpha2>IN</alpha2>
<alpha3>IND</alpha3>
<iso>356</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Индонезия</name>
<fullname>Республика Индонезия</fullname>
<english>Indonesia</english>
<alpha2>ID</alpha2>
<alpha3>IDN</alpha3>
<iso>360</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Иордания</name>
<fullname>Иорданское Хашимитское Королевство</fullname>
<english>Jordan</english>
<alpha2>JO</alpha2>
<alpha3>JOR</alpha3>
<iso>400</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Ирак</name>
<fullname>Республика Ирак</fullname>
<english>Iraq</english>
<alpha2>IQ</alpha2>
<alpha3>IRQ</alpha3>
<iso>368</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Иран, Исламская Республика</name>
<fullname>Исламская Республика Иран</fullname>
<english>Iran, Islamic Republic of</english>
<alpha2>IR</alpha2>
<alpha3>IRN</alpha3>
<iso>364</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Ирландия</name>
<fullname></fullname>
<english>Ireland</english>
<alpha2>IE</alpha2>
<alpha3>IRL</alpha3>
<iso>372</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Исландия</name>
<fullname>Республика Исландия</fullname>
<english>Iceland</english>
<alpha2>IS</alpha2>
<alpha3>ISL</alpha3>
<iso>352</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Испания</name>
<fullname>Королевство Испания</fullname>
<english>Spain</english>
<alpha2>ES</alpha2>
<alpha3>ESP</alpha3>
<iso>724</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Италия</name>
<fullname>Итальянская Республика</fullname>
<english>Italy</english>
<alpha2>IT</alpha2>
<alpha3>ITA</alpha3>
<iso>380</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Йемен</name>
<fullname>Йеменская Республика</fullname>
<english>Yemen</english>
<alpha2>YE</alpha2>
<alpha3>YEM</alpha3>
<iso>887</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Кабо-Верде</name>
<fullname>Республика Кабо-Верде</fullname>
<english>Cape Verde</english>
<alpha2>CV</alpha2>
<alpha3>CPV</alpha3>
<iso>132</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Казахстан</name>
<fullname>Республика Казахстан</fullname>
<english>Kazakhstan</english>
<alpha2>KZ</alpha2>
<alpha3>KAZ</alpha3>
<iso>398</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Камбоджа</name>
<fullname>Королевство Камбоджа</fullname>
<english>Cambodia</english>
<alpha2>KH</alpha2>
<alpha3>KHM</alpha3>
<iso>116</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Камерун</name>
<fullname>Республика Камерун</fullname>
<english>Cameroon</english>
<alpha2>CM</alpha2>
<alpha3>CMR</alpha3>
<iso>120</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Канада</name>
<fullname></fullname>
<english>Canada</english>
<alpha2>CA</alpha2>
<alpha3>CAN</alpha3>
<iso>124</iso>
<location>Америка</location>
<location-precise>Северная Америка</location-precise>
</country>
<country>
<name>Катар</name>
<fullname>Государство Катар</fullname>
<english>Qatar</english>
<alpha2>QA</alpha2>
<alpha3>QAT</alpha3>
<iso>634</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Кения</name>
<fullname>Республика Кения</fullname>
<english>Kenya</english>
<alpha2>KE</alpha2>
<alpha3>KEN</alpha3>
<iso>404</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Кипр</name>
<fullname>Республика Кипр</fullname>
<english>Cyprus</english>
<alpha2>CY</alpha2>
<alpha3>CYP</alpha3>
<iso>196</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Киргизия</name>
<fullname>Киргизская Республика</fullname>
<english>Kyrgyzstan</english>
<alpha2>KG</alpha2>
<alpha3>KGZ</alpha3>
<iso>417</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Кирибати</name>
<fullname>Республика Кирибати</fullname>
<english>Kiribati</english>
<alpha2>KI</alpha2>
<alpha3>KIR</alpha3>
<iso>296</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Китай</name>
<fullname>Китайская Народная Республика</fullname>
<english>China</english>
<alpha2>CN</alpha2>
<alpha3>CHN</alpha3>
<iso>156</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Кокосовые (Килинг) острова</name>
<fullname></fullname>
<english>Cocos (Keeling) Islands</english>
<alpha2>CC</alpha2>
<alpha3>CCK</alpha3>
<iso>166</iso>
<location>Океания</location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Колумбия</name>
<fullname>Республика Колумбия</fullname>
<english>Colombia</english>
<alpha2>CO</alpha2>
<alpha3>COL</alpha3>
<iso>170</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Коморы</name>
<fullname>Союз Коморы</fullname>
<english>Comoros</english>
<alpha2>KM</alpha2>
<alpha3>COM</alpha3>
<iso>174</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Конго</name>
<fullname>Республика Конго</fullname>
<english>Congo</english>
<alpha2>CG</alpha2>
<alpha3>COG</alpha3>
<iso>178</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Конго, Демократическая Республика</name>
<fullname>Демократическая Республика Конго</fullname>
<english>Congo, Democratic Republic of the</english>
<alpha2>CD</alpha2>
<alpha3>COD</alpha3>
<iso>180</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Корея, Народно-Демократическая Республика</name>
<fullname>Корейская Народно-Демократическая Республика</fullname>
<english>Korea, Democratic People''s republic of</english>
<alpha2>KP</alpha2>
<alpha3>PRK</alpha3>
<iso>408</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Корея, Республика</name>
<fullname>Республика Корея</fullname>
<english>Korea, Republic of</english>
<alpha2>KR</alpha2>
<alpha3>KOR</alpha3>
<iso>410</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Коста-Рика</name>
<fullname>Республика Коста-Рика</fullname>
<english>Costa Rica</english>
<alpha2>CR</alpha2>
<alpha3>CRI</alpha3>
<iso>188</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Кот д''Ивуар</name>
<fullname>Республика Кот д''Ивуар</fullname>
<english>Cote d''Ivoire</english>
<alpha2>CI</alpha2>
<alpha3>CIV</alpha3>
<iso>384</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Куба</name>
<fullname>Республика Куба</fullname>
<english>Cuba</english>
<alpha2>CU</alpha2>
<alpha3>CUB</alpha3>
<iso>192</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Кувейт</name>
<fullname>Государство Кувейт</fullname>
<english>Kuwait</english>
<alpha2>KW</alpha2>
<alpha3>KWT</alpha3>
<iso>414</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Кюрасао</name>
<fullname></fullname>
<english>Curaçao</english>
<alpha2>CW</alpha2>
<alpha3>CUW</alpha3>
<iso>531</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Лаос</name>
<fullname>Лаосская Народно-Демократическая Республика</fullname>
<english>Lao People''s Democratic Republic</english>
<alpha2>LA</alpha2>
<alpha3>LAO</alpha3>
<iso>418</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Латвия</name>
<fullname>Латвийская Республика</fullname>
<english>Latvia</english>
<alpha2>LV</alpha2>
<alpha3>LVA</alpha3>
<iso>428</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Лесото</name>
<fullname>Королевство Лесото</fullname>
<english>Lesotho</english>
<alpha2>LS</alpha2>
<alpha3>LSO</alpha3>
<iso>426</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Ливан</name>
<fullname>Ливанская Республика</fullname>
<english>Lebanon</english>
<alpha2>LB</alpha2>
<alpha3>LBN</alpha3>
<iso>422</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Ливийская Арабская Джамахирия</name>
<fullname>
Социалистическая Народная Ливийская Арабская Джамахирия
</fullname>
<english>Libyan Arab Jamahiriya</english>
<alpha2>LY</alpha2>
<alpha3>LBY</alpha3>
<iso>434</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Либерия</name>
<fullname>Республика Либерия</fullname>
<english>Liberia</english>
<alpha2>LR</alpha2>
<alpha3>LBR</alpha3>
<iso>430</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Лихтенштейн</name>
<fullname>Княжество Лихтенштейн</fullname>
<english>Liechtenstein</english>
<alpha2>LI</alpha2>
<alpha3>LIE</alpha3>
<iso>438</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Литва</name>
<fullname>Литовская Республика</fullname>
<english>Lithuania</english>
<alpha2>LT</alpha2>
<alpha3>LTU</alpha3>
<iso>440</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Люксембург</name>
<fullname>Великое Герцогство Люксембург</fullname>
<english>Luxembourg</english>
<alpha2>LU</alpha2>
<alpha3>LUX</alpha3>
<iso>442</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Маврикий</name>
<fullname>Республика Маврикий</fullname>
<english>Mauritius</english>
<alpha2>MU</alpha2>
<alpha3>MUS</alpha3>
<iso>480</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Мавритания</name>
<fullname>Исламская Республика Мавритания</fullname>
<english>Mauritania</english>
<alpha2>MR</alpha2>
<alpha3>MRT</alpha3>
<iso>478</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Мадагаскар</name>
<fullname>Республика Мадагаскар</fullname>
<english>Madagascar</english>
<alpha2>MG</alpha2>
<alpha3>MDG</alpha3>
<iso>450</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Майотта</name>
<fullname></fullname>
<english>Mayotte</english>
<alpha2>YT</alpha2>
<alpha3>MYT</alpha3>
<iso>175</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Макао</name>
<fullname>Специальный административный регион Китая Макао</fullname>
<english>Macao</english>
<alpha2>MO</alpha2>
<alpha3>MAC</alpha3>
<iso>446</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Малави</name>
<fullname>Республика Малави</fullname>
<english>Malawi</english>
<alpha2>MW</alpha2>
<alpha3>MWI</alpha3>
<iso>454</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Малайзия</name>
<fullname></fullname>
<english>Malaysia</english>
<alpha2>MY</alpha2>
<alpha3>MYS</alpha3>
<iso>458</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Мали</name>
<fullname>Республика Мали</fullname>
<english>Mali</english>
<alpha2>ML</alpha2>
<alpha3>MLI</alpha3>
<iso>466</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>
Малые Тихоокеанские отдаленные острова Соединенных Штатов
</name>
<fullname></fullname>
<english>United States Minor Outlying Islands</english>
<alpha2>UM</alpha2>
<alpha3>UMI</alpha3>
<iso>581</iso>
<location>Океания</location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Мальдивы</name>
<fullname>Мальдивская Республика</fullname>
<english>Maldives</english>
<alpha2>MV</alpha2>
<alpha3>MDV</alpha3>
<iso>462</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Мальта</name>
<fullname>Республика Мальта</fullname>
<english>Malta</english>
<alpha2>MT</alpha2>
<alpha3>MLT</alpha3>
<iso>470</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Марокко</name>
<fullname>Королевство Марокко</fullname>
<english>Morocco</english>
<alpha2>MA</alpha2>
<alpha3>MAR</alpha3>
<iso>504</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Мартиника</name>
<fullname></fullname>
<english>Martinique</english>
<alpha2>MQ</alpha2>
<alpha3>MTQ</alpha3>
<iso>474</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Маршалловы острова</name>
<fullname>Республика Маршалловы острова</fullname>
<english>Marshall Islands</english>
<alpha2>MH</alpha2>
<alpha3>MHL</alpha3>
<iso>584</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Мексика</name>
<fullname>Мексиканские Соединенные Штаты</fullname>
<english>Mexico</english>
<alpha2>MX</alpha2>
<alpha3>MEX</alpha3>
<iso>484</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Микронезия, Федеративные Штаты</name>
<fullname>Федеративные штаты Микронезии</fullname>
<english>Micronesia, Federated States of</english>
<alpha2>FM</alpha2>
<alpha3>FSM</alpha3>
<iso>583</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Мозамбик</name>
<fullname>Республика Мозамбик</fullname>
<english>Mozambique</english>
<alpha2>MZ</alpha2>
<alpha3>MOZ</alpha3>
<iso>508</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Молдова, Республика</name>
<fullname>Республика Молдова</fullname>
<english>Moldova</english>
<alpha2>MD</alpha2>
<alpha3>MDA</alpha3>
<iso>498</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Монако</name>
<fullname>Княжество Монако</fullname>
<english>Monaco</english>
<alpha2>MC</alpha2>
<alpha3>MCO</alpha3>
<iso>492</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Монголия</name>
<fullname></fullname>
<english>Mongolia</english>
<alpha2>MN</alpha2>
<alpha3>MNG</alpha3>
<iso>496</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Монтсеррат</name>
<fullname></fullname>
<english>Montserrat</english>
<alpha2>MS</alpha2>
<alpha3>MSR</alpha3>
<iso>500</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Мьянма</name>
<fullname>Союз Мьянма</fullname>
<english>Myanmar</english>
<alpha2>MM</alpha2>
<alpha3>MMR</alpha3>
<iso>104</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Намибия</name>
<fullname>Республика Намибия</fullname>
<english>Namibia</english>
<alpha2>NA</alpha2>
<alpha3>NAM</alpha3>
<iso>516</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Науру</name>
<fullname>Республика Науру</fullname>
<english>Nauru</english>
<alpha2>NR</alpha2>
<alpha3>NRU</alpha3>
<iso>520</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Непал</name>
<fullname>Федеративная Демократическая Республика Непал</fullname>
<english>Nepal</english>
<alpha2>NP</alpha2>
<alpha3>NPL</alpha3>
<iso>524</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Нигер</name>
<fullname>Республика Нигер</fullname>
<english>Niger</english>
<alpha2>NE</alpha2>
<alpha3>NER</alpha3>
<iso>562</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Нигерия</name>
<fullname>Федеративная Республика Нигерия</fullname>
<english>Nigeria</english>
<alpha2>NG</alpha2>
<alpha3>NGA</alpha3>
<iso>566</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Нидерланды</name>
<fullname>Королевство Нидерландов</fullname>
<english>Netherlands</english>
<alpha2>NL</alpha2>
<alpha3>NLD</alpha3>
<iso>528</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Никарагуа</name>
<fullname>Республика Никарагуа</fullname>
<english>Nicaragua</english>
<alpha2>NI</alpha2>
<alpha3>NIC</alpha3>
<iso>558</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Ниуэ</name>
<fullname>Республика Ниуэ</fullname>
<english>Niue</english>
<alpha2>NU</alpha2>
<alpha3>NIU</alpha3>
<iso>570</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Новая Зеландия</name>
<fullname></fullname>
<english>New Zealand</english>
<alpha2>NZ</alpha2>
<alpha3>NZL</alpha3>
<iso>554</iso>
<location>Океания</location>
<location-precise>Австралия и Новая Зеландия</location-precise>
</country>
<country>
<name>Новая Каледония</name>
<fullname></fullname>
<english>New Caledonia</english>
<alpha2>NC</alpha2>
<alpha3>NCL</alpha3>
<iso>540</iso>
<location>Океания</location>
<location-precise>Меланезия</location-precise>
</country>
<country>
<name>Норвегия</name>
<fullname>Королевство Норвегия</fullname>
<english>Norway</english>
<alpha2>NO</alpha2>
<alpha3>NOR</alpha3>
<iso>578</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Объединенные Арабские Эмираты</name>
<fullname></fullname>
<english>United Arab Emirates</english>
<alpha2>AE</alpha2>
<alpha3>ARE</alpha3>
<iso>784</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Оман</name>
<fullname>Султанат Оман</fullname>
<english>Oman</english>
<alpha2>OM</alpha2>
<alpha3>OMN</alpha3>
<iso>512</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Остров Буве</name>
<fullname></fullname>
<english>Bouvet Island</english>
<alpha2>BV</alpha2>
<alpha3>BVT</alpha3>
<iso>074</iso>
<location></location>
<location-precise>Южный океан</location-precise>
</country>
<country>
<name>Остров Мэн</name>
<fullname></fullname>
<english>Isle of Man</english>
<alpha2>IM</alpha2>
<alpha3>IMN</alpha3>
<iso>833</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Остров Норфолк</name>
<fullname></fullname>
<english>Norfolk Island</english>
<alpha2>NF</alpha2>
<alpha3>NFK</alpha3>
<iso>574</iso>
<location>Океания</location>
<location-precise>Австралия и Новая Зеландия</location-precise>
</country>
<country>
<name>Остров Рождества</name>
<fullname></fullname>
<english>Christmas Island</english>
<alpha2>CX</alpha2>
<alpha3>CXR</alpha3>
<iso>162</iso>
<location>Азия</location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Остров Херд и острова Макдональд</name>
<fullname></fullname>
<english>Heard Island and McDonald Islands</english>
<alpha2>HM</alpha2>
<alpha3>HMD</alpha3>
<iso>334</iso>
<location></location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Острова Кайман</name>
<fullname></fullname>
<english>Cayman Islands</english>
<alpha2>KY</alpha2>
<alpha3>CYM</alpha3>
<iso>136</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Острова Кука</name>
<fullname></fullname>
<english>Cook Islands</english>
<alpha2>CK</alpha2>
<alpha3>COK</alpha3>
<iso>184</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Острова Теркс и Кайкос</name>
<fullname></fullname>
<english>Turks and Caicos Islands</english>
<alpha2>TC</alpha2>
<alpha3>TCA</alpha3>
<iso>796</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Пакистан</name>
<fullname>Исламская Республика Пакистан</fullname>
<english>Pakistan</english>
<alpha2>PK</alpha2>
<alpha3>PAK</alpha3>
<iso>586</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Палау</name>
<fullname>Республика Палау</fullname>
<english>Palau</english>
<alpha2>PW</alpha2>
<alpha3>PLW</alpha3>
<iso>585</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Палестинская территория, оккупированная</name>
<fullname>Оккупированная Палестинская территория</fullname>
<english>Palestinian Territory, Occupied</english>
<alpha2>PS</alpha2>
<alpha3>PSE</alpha3>
<iso>275</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Панама</name>
<fullname>Республика Панама</fullname>
<english>Panama</english>
<alpha2>PA</alpha2>
<alpha3>PAN</alpha3>
<iso>591</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Папский Престол (Государство — город Ватикан)</name>
<fullname></fullname>
<english>Holy See (Vatican City State)</english>
<alpha2>VA</alpha2>
<alpha3>VAT</alpha3>
<iso>336</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Папуа-Новая Гвинея</name>
<fullname></fullname>
<english>Papua New Guinea</english>
<alpha2>PG</alpha2>
<alpha3>PNG</alpha3>
<iso>598</iso>
<location>Океания</location>
<location-precise>Меланезия</location-precise>
</country>
<country>
<name>Парагвай</name>
<fullname>Республика Парагвай</fullname>
<english>Paraguay</english>
<alpha2>PY</alpha2>
<alpha3>PRY</alpha3>
<iso>600</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Перу</name>
<fullname>Республика Перу</fullname>
<english>Peru</english>
<alpha2>PE</alpha2>
<alpha3>PER</alpha3>
<iso>604</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Питкерн</name>
<fullname></fullname>
<english>Pitcairn</english>
<alpha2>PN</alpha2>
<alpha3>PCN</alpha3>
<iso>612</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Польша</name>
<fullname>Республика Польша</fullname>
<english>Poland</english>
<alpha2>PL</alpha2>
<alpha3>POL</alpha3>
<iso>616</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Португалия</name>
<fullname>Португальская Республика</fullname>
<english>Portugal</english>
<alpha2>PT</alpha2>
<alpha3>PRT</alpha3>
<iso>620</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Пуэрто-Рико</name>
<fullname></fullname>
<english>Puerto Rico</english>
<alpha2>PR</alpha2>
<alpha3>PRI</alpha3>
<iso>630</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Республика Македония</name>
<fullname></fullname>
<english>Macedonia, The Former Yugoslav Republic Of</english>
<alpha2>MK</alpha2>
<alpha3>MKD</alpha3>
<iso>807</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Реюньон</name>
<fullname></fullname>
<english>Reunion</english>
<alpha2>RE</alpha2>
<alpha3>REU</alpha3>
<iso>638</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Россия</name>
<fullname>Российская Федерация</fullname>
<english>Russian Federation</english>
<alpha2>RU</alpha2>
<alpha3>RUS</alpha3>
<iso>643</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Руанда</name>
<fullname>Руандийская Республика</fullname>
<english>Rwanda</english>
<alpha2>RW</alpha2>
<alpha3>RWA</alpha3>
<iso>646</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Румыния</name>
<fullname></fullname>
<english>Romania</english>
<alpha2>RO</alpha2>
<alpha3>ROU</alpha3>
<iso>642</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Самоа</name>
<fullname>Независимое Государство Самоа</fullname>
<english>Samoa</english>
<alpha2>WS</alpha2>
<alpha3>WSM</alpha3>
<iso>882</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Сан-Марино</name>
<fullname>Республика Сан-Марино</fullname>
<english>San Marino</english>
<alpha2>SM</alpha2>
<alpha3>SMR</alpha3>
<iso>674</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Сан-Томе и Принсипи</name>
<fullname>Демократическая Республика Сан-Томе и Принсипи</fullname>
<english>Sao Tome and Principe</english>
<alpha2>ST</alpha2>
<alpha3>STP</alpha3>
<iso>678</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Саудовская Аравия</name>
<fullname>Королевство Саудовская Аравия</fullname>
<english>Saudi Arabia</english>
<alpha2>SA</alpha2>
<alpha3>SAU</alpha3>
<iso>682</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Свазиленд</name>
<fullname>Королевство Свазиленд</fullname>
<english>Swaziland</english>
<alpha2>SZ</alpha2>
<alpha3>SWZ</alpha3>
<iso>748</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Святая Елена, Остров вознесения, Тристан-да-Кунья</name>
<fullname></fullname>
<english>Saint Helena, Ascension And Tristan Da Cunha</english>
<alpha2>SH</alpha2>
<alpha3>SHN</alpha3>
<iso>654</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Северные Марианские острова</name>
<fullname>Содружество Северных Марианских островов</fullname>
<english>Northern Mariana Islands</english>
<alpha2>MP</alpha2>
<alpha3>MNP</alpha3>
<iso>580</iso>
<location>Океания</location>
<location-precise>Микронезия</location-precise>
</country>
<country>
<name>Сен-Бартельми</name>
<fullname></fullname>
<english>Saint Barthélemy</english>
<alpha2>BL</alpha2>
<alpha3>BLM</alpha3>
<iso>652</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сен-Мартен</name>
<fullname></fullname>
<english>Saint Martin (French Part)</english>
<alpha2>MF</alpha2>
<alpha3>MAF</alpha3>
<iso>663</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сенегал</name>
<fullname>Республика Сенегал</fullname>
<english>Senegal</english>
<alpha2>SN</alpha2>
<alpha3>SEN</alpha3>
<iso>686</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Сент-Винсент и Гренадины</name>
<fullname></fullname>
<english>Saint Vincent and the Grenadines</english>
<alpha2>VC</alpha2>
<alpha3>VCT</alpha3>
<iso>670</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сент-Люсия</name>
<fullname></fullname>
<english>Saint Lucia</english>
<alpha2>LC</alpha2>
<alpha3>LCA</alpha3>
<iso>662</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сент-Китс и Невис</name>
<fullname></fullname>
<english>Saint Kitts and Nevis</english>
<alpha2>KN</alpha2>
<alpha3>KNA</alpha3>
<iso>659</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сент-Пьер и Микелон</name>
<fullname></fullname>
<english>Saint Pierre and Miquelon</english>
<alpha2>PM</alpha2>
<alpha3>SPM</alpha3>
<iso>666</iso>
<location>Америка</location>
<location-precise>Северная Америка</location-precise>
</country>
<country>
<name>Сербия</name>
<fullname>Республика Сербия</fullname>
<english>Serbia</english>
<alpha2>RS</alpha2>
<alpha3>SRB</alpha3>
<iso>688</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Сейшелы</name>
<fullname>Республика Сейшелы</fullname>
<english>Seychelles</english>
<alpha2>SC</alpha2>
<alpha3>SYC</alpha3>
<iso>690</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Сингапур</name>
<fullname>Республика Сингапур</fullname>
<english>Singapore</english>
<alpha2>SG</alpha2>
<alpha3>SGP</alpha3>
<iso>702</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Синт-Мартен</name>
<fullname></fullname>
<english>Sint Maarten</english>
<alpha2>SX</alpha2>
<alpha3>SXM</alpha3>
<iso>534</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Сирийская Арабская Республика</name>
<fullname></fullname>
<english>Syrian Arab Republic</english>
<alpha2>SY</alpha2>
<alpha3>SYR</alpha3>
<iso>760</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Словакия</name>
<fullname>Словацкая Республика</fullname>
<english>Slovakia</english>
<alpha2>SK</alpha2>
<alpha3>SVK</alpha3>
<iso>703</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Словения</name>
<fullname>Республика Словения</fullname>
<english>Slovenia</english>
<alpha2>SI</alpha2>
<alpha3>SVN</alpha3>
<iso>705</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Соединенное Королевство</name>
<fullname>
Соединенное Королевство Великобритании и Северной Ирландии
</fullname>
<english>United Kingdom</english>
<alpha2>GB</alpha2>
<alpha3>GBR</alpha3>
<iso>826</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Соединенные Штаты</name>
<fullname>Соединенные Штаты Америки</fullname>
<english>United States</english>
<alpha2>US</alpha2>
<alpha3>USA</alpha3>
<iso>840</iso>
<location>Америка</location>
<location-precise>Северная Америка</location-precise>
</country>
<country>
<name>Соломоновы острова</name>
<fullname></fullname>
<english>Solomon Islands</english>
<alpha2>SB</alpha2>
<alpha3>SLB</alpha3>
<iso>090</iso>
<location>Океания</location>
<location-precise>Меланезия</location-precise>
</country>
<country>
<name>Сомали</name>
<fullname>Сомалийская Республика</fullname>
<english>Somalia</english>
<alpha2>SO</alpha2>
<alpha3>SOM</alpha3>
<iso>706</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Судан</name>
<fullname>Республика Судан</fullname>
<english>Sudan</english>
<alpha2>SD</alpha2>
<alpha3>SDN</alpha3>
<iso>736</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Суринам</name>
<fullname>Республика Суринам</fullname>
<english>Suriname</english>
<alpha2>SR</alpha2>
<alpha3>SUR</alpha3>
<iso>740</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Сьерра-Леоне</name>
<fullname>Республика Сьерра-Леоне</fullname>
<english>Sierra Leone</english>
<alpha2>SL</alpha2>
<alpha3>SLE</alpha3>
<iso>694</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Таджикистан</name>
<fullname>Республика Таджикистан</fullname>
<english>Tajikistan</english>
<alpha2>TJ</alpha2>
<alpha3>TJK</alpha3>
<iso>762</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Таиланд</name>
<fullname>Королевство Таиланд</fullname>
<english>Thailand</english>
<alpha2>TH</alpha2>
<alpha3>THA</alpha3>
<iso>764</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Тайвань (Китай)</name>
<fullname></fullname>
<english>Taiwan, Province of China</english>
<alpha2>TW</alpha2>
<alpha3>TWN</alpha3>
<iso>158</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
<country>
<name>Танзания, Объединенная Республика</name>
<fullname>Объединенная Республика Танзания</fullname>
<english>Tanzania, United Republic Of</english>
<alpha2>TZ</alpha2>
<alpha3>TZA</alpha3>
<iso>834</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Тимор-Лесте</name>
<fullname>Демократическая Республика Тимор-Лесте</fullname>
<english>Timor-Leste</english>
<alpha2>TL</alpha2>
<alpha3>TLS</alpha3>
<iso>626</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Того</name>
<fullname>Тоголезская Республика</fullname>
<english>Togo</english>
<alpha2>TG</alpha2>
<alpha3>TGO</alpha3>
<iso>768</iso>
<location>Африка</location>
<location-precise>Западная Африка</location-precise>
</country>
<country>
<name>Токелау</name>
<fullname></fullname>
<english>Tokelau</english>
<alpha2>TK</alpha2>
<alpha3>TKL</alpha3>
<iso>772</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Тонга</name>
<fullname>Королевство Тонга</fullname>
<english>Tonga</english>
<alpha2>TO</alpha2>
<alpha3>TON</alpha3>
<iso>776</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Тринидад и Тобаго</name>
<fullname>Республика Тринидад и Тобаго</fullname>
<english>Trinidad and Tobago</english>
<alpha2>TT</alpha2>
<alpha3>TTO</alpha3>
<iso>780</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Тувалу</name>
<fullname></fullname>
<english>Tuvalu</english>
<alpha2>TV</alpha2>
<alpha3>TUV</alpha3>
<iso>798</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Тунис</name>
<fullname>Тунисская Республика</fullname>
<english>Tunisia</english>
<alpha2>TN</alpha2>
<alpha3>TUN</alpha3>
<iso>788</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Туркмения</name>
<fullname>Туркменистан</fullname>
<english>Turkmenistan</english>
<alpha2>TM</alpha2>
<alpha3>TKM</alpha3>
<iso>795</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Турция</name>
<fullname>Турецкая Республика</fullname>
<english>Turkey</english>
<alpha2>TR</alpha2>
<alpha3>TUR</alpha3>
<iso>792</iso>
<location>Азия</location>
<location-precise>Западная Азия</location-precise>
</country>
<country>
<name>Уганда</name>
<fullname>Республика Уганда</fullname>
<english>Uganda</english>
<alpha2>UG</alpha2>
<alpha3>UGA</alpha3>
<iso>800</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Узбекистан</name>
<fullname>Республика Узбекистан</fullname>
<english>Uzbekistan</english>
<alpha2>UZ</alpha2>
<alpha3>UZB</alpha3>
<iso>860</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Украина</name>
<fullname></fullname>
<english>Ukraine</english>
<alpha2>UA</alpha2>
<alpha3>UKR</alpha3>
<iso>804</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Уоллис и Футуна</name>
<fullname></fullname>
<english>Wallis and Futuna</english>
<alpha2>WF</alpha2>
<alpha3>WLF</alpha3>
<iso>876</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Уругвай</name>
<fullname>Восточная Республика Уругвай</fullname>
<english>Uruguay</english>
<alpha2>UY</alpha2>
<alpha3>URY</alpha3>
<iso>858</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Фарерские острова</name>
<fullname></fullname>
<english>Faroe Islands</english>
<alpha2>FO</alpha2>
<alpha3>FRO</alpha3>
<iso>234</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Фиджи</name>
<fullname>Республика островов Фиджи</fullname>
<english>Fiji</english>
<alpha2>FJ</alpha2>
<alpha3>FJI</alpha3>
<iso>242</iso>
<location>Океания</location>
<location-precise>Меланезия</location-precise>
</country>
<country>
<name>Филиппины</name>
<fullname>Республика Филиппины</fullname>
<english>Philippines</english>
<alpha2>PH</alpha2>
<alpha3>PHL</alpha3>
<iso>608</iso>
<location>Азия</location>
<location-precise>Юго-Восточная Азия</location-precise>
</country>
<country>
<name>Финляндия</name>
<fullname>Финляндская Республика</fullname>
<english>Finland</english>
<alpha2>FI</alpha2>
<alpha3>FIN</alpha3>
<iso>246</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Фолклендские острова (Мальвинские)</name>
<fullname></fullname>
<english>Falkland Islands (Malvinas)</english>
<alpha2>FK</alpha2>
<alpha3>FLK</alpha3>
<iso>238</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Франция</name>
<fullname>Французская Республика</fullname>
<english>France</english>
<alpha2>FR</alpha2>
<alpha3>FRA</alpha3>
<iso>250</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Французская Гвиана</name>
<fullname></fullname>
<english>French Guiana</english>
<alpha2>GF</alpha2>
<alpha3>GUF</alpha3>
<iso>254</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Французская Полинезия</name>
<fullname></fullname>
<english>French Polynesia</english>
<alpha2>PF</alpha2>
<alpha3>PYF</alpha3>
<iso>258</iso>
<location>Океания</location>
<location-precise>Полинезия</location-precise>
</country>
<country>
<name>Французские Южные территории</name>
<fullname></fullname>
<english>French Southern Territories</english>
<alpha2>TF</alpha2>
<alpha3>ATF</alpha3>
<iso>260</iso>
<location></location>
<location-precise>Индийский океан</location-precise>
</country>
<country>
<name>Хорватия</name>
<fullname>Республика Хорватия</fullname>
<english>Croatia</english>
<alpha2>HR</alpha2>
<alpha3>HRV</alpha3>
<iso>191</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Центрально-Африканская Республика</name>
<fullname></fullname>
<english>Central African Republic</english>
<alpha2>CF</alpha2>
<alpha3>CAF</alpha3>
<iso>140</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Чад</name>
<fullname>Республика Чад</fullname>
<english>Chad</english>
<alpha2>TD</alpha2>
<alpha3>TCD</alpha3>
<iso>148</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Черногория</name>
<fullname>Республика Черногория</fullname>
<english>Montenegro</english>
<alpha2>ME</alpha2>
<alpha3>MNE</alpha3>
<iso>499</iso>
<location>Европа</location>
<location-precise>Южная Европа</location-precise>
</country>
<country>
<name>Чешская Республика</name>
<fullname></fullname>
<english>Czech Republic</english>
<alpha2>CZ</alpha2>
<alpha3>CZE</alpha3>
<iso>203</iso>
<location>Европа</location>
<location-precise>Восточная Европа</location-precise>
</country>
<country>
<name>Чили</name>
<fullname>Республика Чили</fullname>
<english>Chile</english>
<alpha2>CL</alpha2>
<alpha3>CHL</alpha3>
<iso>152</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Швейцария</name>
<fullname>Швейцарская Конфедерация</fullname>
<english>Switzerland</english>
<alpha2>CH</alpha2>
<alpha3>CHE</alpha3>
<iso>756</iso>
<location>Европа</location>
<location-precise>Западная Европа</location-precise>
</country>
<country>
<name>Швеция</name>
<fullname>Королевство Швеция</fullname>
<english>Sweden</english>
<alpha2>SE</alpha2>
<alpha3>SWE</alpha3>
<iso>752</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Шпицберген и Ян Майен</name>
<fullname></fullname>
<english>Svalbard and Jan Mayen</english>
<alpha2>SJ</alpha2>
<alpha3>SJM</alpha3>
<iso>744</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Шри-Ланка</name>
<fullname>
Демократическая Социалистическая Республика Шри-Ланка
</fullname>
<english>Sri Lanka</english>
<alpha2>LK</alpha2>
<alpha3>LKA</alpha3>
<iso>144</iso>
<location>Азия</location>
<location-precise>Южная часть Центральной Азии</location-precise>
</country>
<country>
<name>Эквадор</name>
<fullname>Республика Эквадор</fullname>
<english>Ecuador</english>
<alpha2>EC</alpha2>
<alpha3>ECU</alpha3>
<iso>218</iso>
<location>Америка</location>
<location-precise>Южная Америка</location-precise>
</country>
<country>
<name>Экваториальная Гвинея</name>
<fullname>Республика Экваториальная Гвинея</fullname>
<english>Equatorial Guinea</english>
<alpha2>GQ</alpha2>
<alpha3>GNQ</alpha3>
<iso>226</iso>
<location>Африка</location>
<location-precise>Центральная Африка</location-precise>
</country>
<country>
<name>Эландские острова</name>
<fullname></fullname>
<english>Åland Islands</english>
<alpha2>AX</alpha2>
<alpha3>ALA</alpha3>
<iso>248</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Эль-Сальвадор</name>
<fullname>Республика Эль-Сальвадор</fullname>
<english>El Salvador</english>
<alpha2>SV</alpha2>
<alpha3>SLV</alpha3>
<iso>222</iso>
<location>Америка</location>
<location-precise>Центральная Америка</location-precise>
</country>
<country>
<name>Эритрея</name>
<fullname></fullname>
<english>Eritrea</english>
<alpha2>ER</alpha2>
<alpha3>ERI</alpha3>
<iso>232</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Эстония</name>
<fullname>Эстонская Республика</fullname>
<english>Estonia</english>
<alpha2>EE</alpha2>
<alpha3>EST</alpha3>
<iso>233</iso>
<location>Европа</location>
<location-precise>Северная Европа</location-precise>
</country>
<country>
<name>Эфиопия</name>
<fullname>Федеративная Демократическая Республика Эфиопия</fullname>
<english>Ethiopia</english>
<alpha2>ET</alpha2>
<alpha3>ETH</alpha3>
<iso>231</iso>
<location>Африка</location>
<location-precise>Восточная Африка</location-precise>
</country>
<country>
<name>Южная Африка</name>
<fullname>Южно-Африканская Республика</fullname>
<english>South Africa</english>
<alpha2>ZA</alpha2>
<alpha3>ZAF</alpha3>
<iso>710</iso>
<location>Африка</location>
<location-precise>Южная часть Африки</location-precise>
</country>
<country>
<name>Южная Джорджия и Южные Сандвичевы острова</name>
<fullname></fullname>
<english>South Georgia and the South Sandwich Islands</english>
<alpha2>GS</alpha2>
<alpha3>SGS</alpha3>
<iso>239</iso>
<location></location>
<location-precise>Южный океан</location-precise>
</country>
<country>
<name>Южная Осетия</name>
<fullname>Республика Южная Осетия</fullname>
<english>South Ossetia</english>
<alpha2>OS</alpha2>
<alpha3>OST</alpha3>
<iso>896</iso>
<location>Азия</location>
<location-precise>Закавказье</location-precise>
</country>
<country>
<name>Южный Судан</name>
<fullname></fullname>
<english>South Sudan</english>
<alpha2>SS</alpha2>
<alpha3>SSD</alpha3>
<iso>728</iso>
<location>Африка</location>
<location-precise>Северная Африка</location-precise>
</country>
<country>
<name>Ямайка</name>
<fullname></fullname>
<english>Jamaica</english>
<alpha2>JM</alpha2>
<alpha3>JAM</alpha3>
<iso>388</iso>
<location>Америка</location>
<location-precise>Карибский бассейн</location-precise>
</country>
<country>
<name>Япония</name>
<fullname></fullname>
<english>Japan</english>
<alpha2>JP</alpha2>
<alpha3>JPN</alpha3>
<iso>392</iso>
<location>Азия</location>
<location-precise>Восточная Азия</location-precise>
</country>
</country-list>';
with coutr as (
select 
	c.data.value('name[1]','varchar(100)') as name,
	c.data.value('fullname[1]','varchar(150)') as fullname,
	c.data.value('english[1]','varchar(50)') as english,
	c.data.value('alpha2[1]','char(2)') as alpha2,
	c.data.value('alpha3[1]','char(3)') as alpha3,
	c.data.value('iso[1]','char(3)') as iso,
	c.data.value('location[1]','varchar(10)') as location,
	c.data.value('location-precise[1]','varchar(30)') as [location-precise]
from  @country.nodes('country-list/country') c(data)
)
select /* -- max length
	   max(len(coutr.name)) ,
       max(len(coutr.fullname)) ,
       max(len(coutr.english)) ,
       max(len(coutr.alpha2)) ,
       max(len(coutr.alpha3)) ,
       max(len(coutr.iso)) ,
       max(len(coutr.location)) ,
       max(len(coutr.[location-precise]))
	   */
	   *
from coutr
/*
<header>
<name>Наименование</name>
<fullname>Полное наименование</fullname>
<english>На английском</english>
<alpha2>Alpha2</alpha2>
<alpha3>Alpha3</alpha3>
<iso>ISO</iso>
<location>Часть света</location>
<location-precise>Расположение</location-precise>
</header>

*/