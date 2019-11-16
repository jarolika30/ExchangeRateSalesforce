import { LightningElement, track, wire } from 'lwc';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import Id from '@salesforce/user/Id';

import getRatesDefaultValue from '@salesforce/apex/DefaultRateController.getRatesDefaultValue';
import addFieldToExchangeRate from '@salesforce/apex/MakeField.addFieldToExchangeRate';
import getDataForDays from '@salesforce/apex/DataForDaysController.getDataForDays';
import getLastdata from '@salesforce/apex/ExchangeDataController.getLastdata';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPE_FIELD from '@salesforce/schema/Exchange_Rate__c.Base_Currency__c';

import Rate from './Rate';
import Currency from './Currency';
import RateForSelectedDate from './RateForSelectedDate';
const URL_SEARCH = 'https://api.exchangeratesapi.io/';

export default class ExchangeRatesAppComponent extends LightningElement {
    //userId = Id;
    @track results = [];
    searchdate = '';

    @track searchHeading = '';
    @track searchResultsTitle = '';
    @track searchBase = '';
    @track subtitle = '';

    @track searchDate = '';
    @track searchResults = [];
    @track searchError = '';
    @track resultsForDates = [];
    @track rates = ['CAD', 'USD', 'EUR'];
    @track date = '';
    @track base = '';
    @track anotherDate = false;
    @track startDate = '';
    @track endDate = '';
    error = false;
    @track absence = '';
    @track message = "";
    @track selectedValue = '';
    @track currencies = ['HKD','ISK','PHP','DKK','HUF','CZK','RON','SEK', 'CAD', 'USD', 'EUR',
                        'IDR','INR','BRL','RUB','HRK','JPY','THB','CHF','MYR','BGN','TRY','CNY',
                        'NOK','NZD','ZAR','MXN','SGD','AUD','ILS','KRW','PLN'];

    @track futureCurrencies = [];
    @track search = false;

    @track showModal = false;
    lastEchangeRate;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: TYPE_FIELD
    })
    picklistValues;

    connectedCallback() {
        getRatesDefaultValue()
        .then((res) => {
            this.base = res;
        });

        this.currencies.map(el => {
            this.futureCurrencies.push(new Currency(el, el));
            return el;
        });

        getLastdata()
        .then((data) => {
            let ob = data;
            this.date = this.returnDateForUser(data.Date__c);
            let count = 1;
            for (let key in ob) {
                if (key !== 'Id' && key !== 'Date__c') {
                    let valueOfCurrency = ob[key];
                    let nameOfCurrency = key.slice(0, -3);
                    this.results.push(new Rate(count, nameOfCurrency, valueOfCurrency));
                    count++; 
                }
            }
        })
        .catch((error) => {
            // eslint-disable-next-line no-console
            console.log('error: ' + error.message);
        })

    }

    returnDateForUser(date) {
        let temp = new Date(date);
        const res = temp.getDate() + "." + (temp.getMonth() + 1) + "." + temp.getFullYear();
        return res;
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        this.recalculateRates(this.selectedValue);
    }

    handleNewCurrency(event) {
        this.selectedValue = event.detail.value;
    }

    handleAddCurrency() {
        addFieldToExchangeRate(this.selectedValue)
        .then(()=> {
            this.error = false;
            this.message = 'The new currency is added successfully!!!';
        })
        .catch((error)=> {
            this.error = true;
            this.message = 'The new currency is NOT added!!! Error: ' + error.message;
        });
        this.showModal = true;
    }

    handleChoosedate() {
        this.anotherDate = true;
        this.startDate = '';
    }

    handleStartDate(event) {
        this.startDate = event.target.value;
        this.message = '';
        this.error = false;
    }

    handleEndDate(event) {
        this.endDate = event.target.value;
    }

    handleShowDayOrPeriod() {
        this.resultsForDates = [];
        if (this.startDate !== '') {
            this.anotherDate = false;
            getDataForDays({ startDate: this.startDate, endDate: this.endDate })
            .then((data) => {
                let ob = Object.values(data);
                if (ob.length !== 0) {
                    this.absence = '';
                    for (let i = 0; i < ob.length; i++) {
                        let arrayOfCurrencies = [];
    
                        for (let key in ob[i]) {
                            if (key !== 'Id' && key !== 'Date__c') {
                                let valueOfCurrency = ob[i][key];
                                let nameOfCurrency = key.slice(0, -3);
                                arrayOfCurrencies.push(new Currency(valueOfCurrency, nameOfCurrency));
                            } 
                        }
    
                        this.resultsForDates.push(new RateForSelectedDate(ob[i].Id, ob[i].Date__c, arrayOfCurrencies ));
                    }
                } else {
                    this.searchdate = this.endDate;
                    this.absence = 'Sorry, there is no information for this date in database!';
                    this.search = true;
                    this.searchHeading = 'Do you want searching data on https://exchangeratesapi.io ?';
                    this.subtitle = 'PLEASE, MAKE YOUR CHOISE!';
                }
                this.endDate = '';
            })
            .catch((error) => {
                // eslint-disable-next-line no-console
                console.log('error: ' + error.message);
            });
        } else {
            this.error = true;
            this.message = 'You should fill Start date!!!';
        }
    }

    handleSearch() {
        let requestSearch = URL_SEARCH;
        requestSearch = (this.searchdate === '') ? `${requestSearch}${this.startDate}?&base=${this.base}`
                         : `${requestSearch}history?start_at=${this.startDate}&end_at=${this.searchdate}&base=${this.base}`;                 
        fetch(requestSearch)
            .then((resp) => { 
                return resp.json();
            })
            .then((data) => {
                let ob = Object.values(data).filter(el => typeof el === 'object');
                let tempResult = [];
                let result = [];
                this.searchHeading = '';
                this.subtitle = '';
                this.searchResultsTitle = 'Your Search Results:';
                this.searchBase = `1 ${this.base} equals`;
                
                if (Object.keys(ob).length) {
                    if (this.searchdate === '') {
                        ob = ob[0];

                        this.searchDate = this.returnDateForUser(data.date);
        
                        for (let key in ob) {
                            if (this.rates.includes(key)) {
                            let ob1 = new Currency(ob[key], key);
                            tempResult.push(ob1);
                            }
                        }
                        result.push(new RateForSelectedDate(123, this.searchDate, tempResult ));
                        this.searchResults = result; 
                    } else {
                        // eslint-disable-next-line no-console
                        console.log('data: ' + JSON.stringify(data));
                        // eslint-disable-next-line no-console
                        console.log('ob: ' + JSON.stringify(ob));
                    }
                } else {
                    this.searchResults = [];
                    this.searchError = 'Not found!!!';
                }

            })
            .catch((error)=> {
                this.searchError = error.message;
            });
    }

    handleAddToDatabase() {

    }

    closeModal() {
        this.showModal = false;
        this.anotherDate = false;
        this.startDate = '';
        this.message = '';
        this.error = false;
        this.search = false;
        this.searchResults = [];
        this.searchBase = '';
        this.searchResultsTitle = '';
    }

    recalculateRates(newBase) {
        if (this.results.length !== 0) {
            const newBaseValue = this.results.filter(element => {
              if (element.name === newBase) {
                return element;
              }
              return null;
            });
            
            const lastBaseValue = 1 / newBaseValue[0].valueRate;
            
            let currencies = [];
            let count = 1;
            this.results.map(el => {
              if (el.name !== newBase) {
                const valRate = el.valueRate * lastBaseValue;
                let ob1 = new Rate(count, el.name, valRate.toFixed(10));
                currencies.push(ob1);
                count++;
              }
              return el;
            })
            currencies.push(new Rate(++count, this.base, lastBaseValue.toFixed(10)));
            this.results = currencies;
            this.base = newBase;
        }
    }

    get style_of_message() {
        return this.error ? 'red-font' : 'green-font';
    }
}