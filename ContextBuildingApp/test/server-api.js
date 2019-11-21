var expect = require('chai').expect;
var api = require('supertest')('http://localhost:8000');

describe("Device", function(){
    describe("Get Devices", function(){
        it("Should list all devices of a valid user", function(done) {
            api.get('/api/getDevices/jakka')
            .set('Accept', 'application/json')
            .end(function(err, res){
                expect(res.status).to.equal(200);
                expect(res.body).to.be.a('array');
                expect(res.body[0]).to.have.property('deviceId');
                expect(res.body[0]).to.have.property('ipAddress');
                expect(res.body[0]).to.have.property('aliasName');
                expect(res.body[0]).to.have.property('userName');
                expect(res.body[0]).to.have.property('regDate');
                done();
            });
        });

        it("Should not list any device of a invalid user", function(done){
            api.get('/api/getDevices/invalid')
            .set('Accept', 'application/json')
            .end(function(err, res){
                expect(res.status).to.equal(200);
                expect(res.body).to.be.a('array');
                expect(res.body.length).to.equal(0);
                done();
            });
        });
    });

    describe("Device Parameters", function(){
        it("Should list Parameters of a valid device", function(done){
            api.get('/api/commonPrams/DEV2134')
            .set('Accept', 'application/json')
            .end(function(err, res){
                expect(res.status).to.equal(200);
                expect(res.body).to.be.an('object');
                expect(res.body).to.have.property('rec');
                expect(res.body).to.have.property('serverIP');
                done();
            });
        });
        it("Should not list Parameters of a invalid device", function(done){
            api.get('/api/commonPrams/invalidDevice')
            .set('Accept', 'application/json')
            .end(function(err, res){
                expect(res.status).to.equal(200);
                expect(res.body).to.equal('failed');
                done();
            });
        });
    });
});