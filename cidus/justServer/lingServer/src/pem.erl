%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 4月 2022 11:21
%%%-------------------------------------------------------------------
-module(pem).
-author("USER").
%% API
-compile(export_all).
-include_lib("public_key/include/public_key.hrl").
-include("hdlt_logger.hrl").
-define(PublicKey,publicKey).
-define(PrivateKey,privateKey).


makePem()->
  #'RSAPrivateKey'{modulus = Modulus,publicExponent = PublicExponent}=PrivateKey=public_key:generate_key({rsa,1024,65537}),
  PublicKey=#'RSAPublicKey'{modulus = Modulus,publicExponent = PublicExponent},
  put(?PublicKey,PublicKey),
  put(?PrivateKey,PrivateKey).

en_rsaPri(BinData)->
  public_key:encrypt_private(BinData,get(?PrivateKey)).

en_rsaPub(BinData)->
  public_key:encrypt_public(BinData,get(?PublicKey)).

de_rsaPri(BinData)->
  public_key:decrypt_private(BinData,get(?PrivateKey)).

de_rsaPub(BinData)->
  public_key:decrypt_public(BinData,get(?PublicKey)).

test(Data)->
  case get(?PublicKey) of
    ?UNDEFINED->
      makePem();
    _->
      ok
  end,
  Result1=de_rsaPub(en_rsaPri(Data)),
  Result2 =de_rsaPri(en_rsaPub(Data)),
  {Result1,Result2}.

makePemBinary()->
  file:write_file("createPubPem",makePemPubBinary()),
    file:write_file("createPriPem",makePemPriBinary()).

makePemPubBinary()->
  PemEntry=public_key:pem_entry_encode('SubjectPublicKeyInfo',get(?PublicKey)),
  public_key:pem_encode([PemEntry]).

makePemPriBinary()->
  PemEntry=public_key:pem_entry_encode('RSAPrivateKey',get(?PrivateKey)),
  public_key:pem_encode([PemEntry]).

