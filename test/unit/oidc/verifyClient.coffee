chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




Client = require '../../../models/Client'
{verifyClient} = require '../../../oidc'




describe 'Verify Client', ->


  {req,res,next,err} = {}


  describe 'with unknown client id', ->

    before (done) ->
      sinon.stub(Client, 'get').callsArgWith(2, null, null)
      req  = { connectParams: {} }
      res  = {}
      next = sinon.spy()

      verifyClient req, res, (error) ->
        err = error
        done()

    after ->
      Client.get.restore()

    it 'should provide an AuthorizationError', ->
      err.name.should.equal 'AuthorizationError'

    it 'should provide an error code', ->
      err.error.should.equal 'unauthorized_client'

    it 'should provide an error description', ->
      err.error_description.should.equal 'Unknown client'

    it 'should provide a status code', ->
      err.statusCode.should.equal 401




  describe 'with mismatching redirect uri', ->

    before (done) ->
      client = { redirect_uris: [] }
      sinon.stub(Client, 'get').callsArgWith(2, null, client)
      req  = { connectParams: { redirect_uri: 'https://mismatching.uri/cb' } }
      res  = {}
      next = sinon.spy()

      verifyClient req, res, (error) ->
        err = error
        done()

    after ->
      Client.get.restore()

    it 'should provide an AuthorizationError', ->
      err.name.should.equal 'AuthorizationError'

    it 'should provide an error code', ->
      err.error.should.equal 'invalid_request'

    it 'should provide an error description', ->
      err.error_description.should.equal 'Mismatching redirect uri'

    it 'should provide a status code', ->
      err.statusCode.should.equal 400




  describe 'with unregistered response_type', ->

    before (done) ->
      client =
        redirect_uris: [ 'https://redirect.uri/cb' ]
        response_types: [ 'code id_token' ]
      sinon.stub(Client, 'get').callsArgWith(2, null, client)
      req  =
        connectParams:
          redirect_uri: 'https://redirect.uri/cb'
          response_type: 'code'
      res  = {}
      next = sinon.spy()

      verifyClient req, res, (error) ->
        err = error
        done()

    after ->
      Client.get.restore()

    it 'should provide an AuthorizationError', ->
      err.name.should.equal 'AuthorizationError'

    it 'should provide an error code', ->
      err.error.should.equal 'unsupported_response_type'

    it 'should provide an error description', ->
      err.error_description.should.equal 'Unsupported response type'

    it 'should provide a redirect_uri', ->
      err.redirect_uri.should.equal 'https://redirect.uri/cb'

    it 'should provide a status code', ->
      err.statusCode.should.equal 302
