public class MakeCalloutMock implements HttpCalloutMock {
	private String responseJson = '{' + 
        '"rates":{' + 
            '"CAD":1.3154922001,"HKD":7.8358436435,"ISK":123.8120853505,'+
            '"PHP":50.8373677604,"DKK":6.6978662363,"HUF":294.6924870002,' +
            '"CZK":22.8698224852,"GBP":0.7722162453,"RON":4.263941187,' +
            '"SEK":9.6376187915,"IDR":14077.0127308589,"INR":70.9274699659,' + 
            '"BRL":3.9908552985,"RUB":63.9805450959,"HRK":6.6863008786,' +
            '"JPY":108.2391967007,"THB":30.1846871078,"CHF":0.9868208714,'+
            '"EUR":0.8965393581,"MYR":4.1785009862,"BGN":1.7534516765,"TRY":5.7124798279,' +
            '"CNY":7.0414201183,"NOK":9.191321499,"NZD":1.5563026717,"ZAR":15.1622736238,' +
            '"USD":1.0,"MXN":19.12004662,"SGD":1.3604088219,"AUD":1.4467455621,"ILS":3.5271651425,' +
            '"KRW":1168.0742334588,"PLN":3.8175542406},' +
		'"base":"USD","date":"2019-10-31"}';

    private String responseJsonPeriod = '{"rates":' +
    '{"2019-11-01":' + 
    	'{"CAD":1.4682,"HKD":8.7298,"ISK":138.1,"PHP":56.286,"DKK":7.4712,"HUF":328.33,"CZK":25.514,' + 
        '"AUD":1.6151,"RON":4.7547,"SEK":10.6993,"IDR":15640.93,"INR":78.816,"BRL":4.4437,"RUB":71.0786,' + 
        '"HRK":7.46,"JPY":120.43,"THB":33.623,"CHF":1.1013,"SGD":1.5129,"PLN":4.2535,"BGN":1.9558,"TRY":6.3761,' + 
        '"CNY":7.844,"NOK":10.1638,"NZD":1.7326,"ZAR":16.828,"USD":1.1139,"MXN":21.3164,"ILS":3.9272,"GBP":0.86008,' + 
        '"KRW":1300.09,"MYR":4.64},' + 
    '"2019-10-31":' + 
    	'{"CAD":1.4673,"HKD":8.7401,"ISK":138.1,"PHP":56.704,"DKK":7.4708,"HUF":328.7,"CZK":25.509,"AUD":1.6137,"RON":4.756,' + 
        '"SEK":10.7498,"IDR":15701.5,"INR":79.1125,"BRL":4.4514,"RUB":71.3639,"HRK":7.4579,"JPY":120.73,"THB":33.668,"CHF":1.1007,' + 
        '"SGD":1.5174,"PLN":4.2581,"BGN":1.9558,"TRY":6.3717,"CNY":7.854,"NOK":10.252,"NZD":1.7359,"ZAR":16.912,"USD":1.1154,"MXN":21.3265,' + 
        '"ILS":3.9342,"GBP":0.86133,"KRW":1302.87,"MYR":4.6607}},' + 
        '"start_at":"2019-10-31","base":"EUR","end_at":"2019-11-02"}';
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseJson);
        response.setStatusCode(200);
        return response; 
    }
}