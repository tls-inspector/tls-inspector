/// This is a modified output from https://github.com/ecnepsnai/FontawesomeProIOS but only using the free icons
import UIKit

/**
 * Enumeration of all FontAwesome icons. Variants are suffixed with "Regular", "Light", or "Solid".
 * Brands are prefixed with "Brand". Duotone icons are not supported on iOS and are not included here.
 *
 * All usable icons can be seen [here](https://fontawesome.com/icons?d=gallery&s=brands,light,regular,solid)
 */
enum FAIcon: Int {
    case FAAdSolid = 400878
    case FAAddressBookRegular = 300058
    case FAAddressBookSolid = 400363
    case FAAddressCardRegular = 300007
    case FAAddressCardSolid = 400042
    case FAAdjustSolid = 400497
    case FAAirFreshenerSolid = 400499
    case FAAlignCenterSolid = 400368
    case FAAlignJustifySolid = 400536
    case FAAlignLeftSolid = 400792
    case FAAlignRightSolid = 400647
    case FAAllergiesSolid = 400839
    case FAAmbulanceSolid = 400052
    case FAAmericanSignLanguageInterpretingSolid = 400406
    case FAAnchorSolid = 400144
    case FAAngleDoubleDownSolid = 400227
    case FAAngleDoubleLeftSolid = 400238
    case FAAngleDoubleRightSolid = 400446
    case FAAngleDoubleUpSolid = 400738
    case FAAngleDownSolid = 400457
    case FAAngleLeftSolid = 400239
    case FAAngleRightSolid = 400347
    case FAAngleUpSolid = 400795
    case FAAngryRegular = 300041
    case FAAngrySolid = 400271
    case FAAnkhSolid = 400566
    case FAAppleAltSolid = 400921
    case FAArchiveSolid = 400405
    case FAArchwaySolid = 400638
    case FAArrowAltCircleDownRegular = 300109
    case FAArrowAltCircleDownSolid = 400626
    case FAArrowAltCircleLeftRegular = 300066
    case FAArrowAltCircleLeftSolid = 400420
    case FAArrowAltCircleRightRegular = 300062
    case FAArrowAltCircleRightSolid = 400381
    case FAArrowAltCircleUpRegular = 300135
    case FAArrowAltCircleUpSolid = 400817
    case FAArrowCircleDownSolid = 400750
    case FAArrowCircleLeftSolid = 400951
    case FAArrowCircleRightSolid = 400438
    case FAArrowCircleUpSolid = 400414
    case FAArrowDownSolid = 400498
    case FAArrowLeftSolid = 400171
    case FAArrowRightSolid = 400873
    case FAArrowUpSolid = 400207
    case FAArrowsAltHSolid = 400610
    case FAArrowsAltSolid = 400910
    case FAArrowsAltVSolid = 400612
    case FAAssistiveListeningSystemsSolid = 400565
    case FAAsteriskSolid = 400220
    case FAAtSolid = 400468
    case FAAtlasSolid = 400741
    case FAAtomSolid = 400710
    case FAAudioDescriptionSolid = 400801
    case FAAwardSolid = 400038
    case FABabyCarriageSolid = 400494
    case FABabySolid = 400774
    case FABackspaceSolid = 400186
    case FABackwardSolid = 400231
    case FABaconSolid = 400022
    case FABalanceScaleLeftSolid = 400594
    case FABalanceScaleRightSolid = 400926
    case FABalanceScaleSolid = 400014
    case FABanSolid = 400122
    case FABandAidSolid = 400958
    case FABarcodeSolid = 400255
    case FABarsSolid = 400625
    case FABaseballBallSolid = 400033
    case FABasketballBallSolid = 400415
    case FABathSolid = 400193
    case FABatteryEmptySolid = 400427
    case FABatteryFullSolid = 400681
    case FABatteryHalfSolid = 400058
    case FABatteryQuarterSolid = 400567
    case FABatteryThreeQuartersSolid = 400045
    case FABedSolid = 400832
    case FABeerSolid = 400139
    case FABellRegular = 300111
    case FABellSlashRegular = 300101
    case FABellSlashSolid = 400596
    case FABellSolid = 400640
    case FABezierCurveSolid = 400111
    case FABibleSolid = 400515
    case FABicycleSolid = 400019
    case FABikingSolid = 400656
    case FABinocularsSolid = 400900
    case FABiohazardSolid = 400335
    case FABirthdayCakeSolid = 400520
    case FABlenderPhoneSolid = 400346
    case FABlenderSolid = 400615
    case FABlindSolid = 400322
    case FABlogSolid = 400760
    case FABoldSolid = 400188
    case FABoltSolid = 400189
    case FABombSolid = 400103
    case FABoneSolid = 400065
    case FABongSolid = 400064
    case FABookDeadSolid = 400214
    case FABookMedicalSolid = 400282
    case FABookOpenSolid = 400290
    case FABookReaderSolid = 400074
    case FABookSolid = 400949
    case FABookmarkRegular = 300052
    case FABookmarkSolid = 400329
    case FABorderAllSolid = 400687
    case FABorderNoneSolid = 400631
    case FABorderStyleSolid = 400937
    case FABowlingBallSolid = 400918
    case FABoxOpenSolid = 400101
    case FABoxSolid = 400260
    case FABoxesSolid = 400172
    case FABrailleSolid = 400692
    case FABrainSolid = 400300
    case FABrands500px = 100007
    case FABrandsAccessibleIcon = 100341
    case FABrandsAccusoft = 100031
    case FABrandsAcquisitionsIncorporated = 100299
    case FABrandsAdn = 100404
    case FABrandsAdobe = 100029
    case FABrandsAdversal = 100127
    case FABrandsAffiliatetheme = 100398
    case FABrandsAirbnb = 100349
    case FABrandsAlgolia = 100074
    case FABrandsAlipay = 100307
    case FABrandsAmazon = 100058
    case FABrandsAmazonPay = 100014
    case FABrandsAmilia = 100167
    case FABrandsAndroid = 100396
    case FABrandsAngellist = 100099
    case FABrandsAngrycreative = 100209
    case FABrandsAngular = 100144
    case FABrandsAppStore = 100085
    case FABrandsAppStoreIos = 100339
    case FABrandsApper = 100120
    case FABrandsApple = 100320
    case FABrandsApplePay = 100306
    case FABrandsArtstation = 100090
    case FABrandsAsymmetrik = 100046
    case FABrandsAtlassian = 100429
    case FABrandsAudible = 100410
    case FABrandsAutoprefixer = 100154
    case FABrandsAvianex = 100279
    case FABrandsAviato = 100326
    case FABrandsAws = 100364
    case FABrandsBandcamp = 100172
    case FABrandsBattleNet = 100215
    case FABrandsBehance = 100355
    case FABrandsBehanceSquare = 100108
    case FABrandsBimobject = 100102
    case FABrandsBitbucket = 100107
    case FABrandsBitcoin = 100041
    case FABrandsBity = 100145
    case FABrandsBlackTie = 100135
    case FABrandsBlackberry = 100189
    case FABrandsBlogger = 100353
    case FABrandsBloggerB = 100012
    case FABrandsBluetooth = 100346
    case FABrandsBluetoothB = 100409
    case FABrandsBootstrap = 100023
    case FABrandsBtc = 100376
    case FABrandsBuffer = 100152
    case FABrandsBuromobelexperte = 100231
    case FABrandsBuyNLarge = 100160
    case FABrandsBuysellads = 100142
    case FABrandsCanadianMapleLeaf = 100123
    case FABrandsCcAmazonPay = 100423
    case FABrandsCcAmex = 100378
    case FABrandsCcApplePay = 100278
    case FABrandsCcDinersClub = 100234
    case FABrandsCcDiscover = 100248
    case FABrandsCcJcb = 100245
    case FABrandsCcMastercard = 100141
    case FABrandsCcPaypal = 100426
    case FABrandsCcStripe = 100006
    case FABrandsCcVisa = 100338
    case FABrandsCentercode = 100408
    case FABrandsCentos = 100086
    case FABrandsChrome = 100068
    case FABrandsChromecast = 100026
    case FABrandsCloudscale = 100428
    case FABrandsCloudsmith = 100071
    case FABrandsCloudversify = 100203
    case FABrandsCodepen = 100262
    case FABrandsCodiepie = 100114
    case FABrandsConfluence = 100289
    case FABrandsConnectdevelop = 100386
    case FABrandsContao = 100164
    case FABrandsCottonBureau = 100267
    case FABrandsCpanel = 100347
    case FABrandsCreativeCommons = 100002
    case FABrandsCreativeCommonsBy = 100227
    case FABrandsCreativeCommonsNc = 100175
    case FABrandsCreativeCommonsNcEu = 100179
    case FABrandsCreativeCommonsNcJp = 100206
    case FABrandsCreativeCommonsNd = 100174
    case FABrandsCreativeCommonsPd = 100217
    case FABrandsCreativeCommonsPdAlt = 100327
    case FABrandsCreativeCommonsRemix = 100150
    case FABrandsCreativeCommonsSa = 100241
    case FABrandsCreativeCommonsSampling = 100383
    case FABrandsCreativeCommonsSamplingPlus = 100079
    case FABrandsCreativeCommonsShare = 100050
    case FABrandsCreativeCommonsZero = 100009
    case FABrandsCriticalRole = 100403
    case FABrandsCss3 = 100405
    case FABrandsCss3Alt = 100419
    case FABrandsCuttlefish = 100302
    case FABrandsDAndD = 100230
    case FABrandsDAndDBeyond = 100124
    case FABrandsDashcube = 100021
    case FABrandsDelicious = 100040
    case FABrandsDeploydog = 100075
    case FABrandsDeskpro = 100392
    case FABrandsDev = 100212
    case FABrandsDeviantart = 100130
    case FABrandsDhl = 100076
    case FABrandsDiaspora = 100237
    case FABrandsDigg = 100043
    case FABrandsDigitalOcean = 100072
    case FABrandsDiscord = 100252
    case FABrandsDiscourse = 100271
    case FABrandsDochub = 100418
    case FABrandsDocker = 100275
    case FABrandsDraft2digital = 100254
    case FABrandsDribbble = 100322
    case FABrandsDribbbleSquare = 100103
    case FABrandsDropbox = 100205
    case FABrandsDrupal = 100235
    case FABrandsDyalog = 100321
    case FABrandsEarlybirds = 100147
    case FABrandsEbay = 100045
    case FABrandsEdge = 100274
    case FABrandsElementor = 100146
    case FABrandsEllo = 100080
    case FABrandsEmber = 100199
    case FABrandsEmpire = 100415
    case FABrandsEnvira = 100414
    case FABrandsErlang = 100027
    case FABrandsEthereum = 100195
    case FABrandsEtsy = 100251
    case FABrandsEvernote = 100091
    case FABrandsExpeditedssl = 100259
    case FABrandsFacebook = 100312
    case FABrandsFacebookF = 100115
    case FABrandsFacebookMessenger = 100224
    case FABrandsFacebookSquare = 100128
    case FABrandsFantasyFlightGames = 100243
    case FABrandsFedex = 100417
    case FABrandsFedora = 100270
    case FABrandsFigma = 100233
    case FABrandsFirefox = 100319
    case FABrandsFirstOrder = 100049
    case FABrandsFirstOrderAlt = 100053
    case FABrandsFirstdraft = 100282
    case FABrandsFlickr = 100377
    case FABrandsFlipboard = 100365
    case FABrandsFly = 100122
    case FABrandsFontAwesome = 100116
    case FABrandsFontAwesomeAlt = 100421
    case FABrandsFontAwesomeFlag = 100180
    case FABrandsFonticons = 100038
    case FABrandsFonticonsFi = 100305
    case FABrandsFortAwesome = 100382
    case FABrandsFortAwesomeAlt = 100028
    case FABrandsForumbee = 100366
    case FABrandsFoursquare = 100113
    case FABrandsFreeCodeCamp = 100200
    case FABrandsFreebsd = 100337
    case FABrandsFulcrum = 100110
    case FABrandsGalacticRepublic = 100393
    case FABrandsGalacticSenate = 100301
    case FABrandsGetPocket = 100384
    case FABrandsGg = 100308
    case FABrandsGgCircle = 100101
    case FABrandsGit = 100139
    case FABrandsGitAlt = 100240
    case FABrandsGitSquare = 100331
    case FABrandsGithub = 100219
    case FABrandsGithubAlt = 100280
    case FABrandsGithubSquare = 100118
    case FABrandsGitkraken = 100017
    case FABrandsGitlab = 100228
    case FABrandsGitter = 100263
    case FABrandsGlide = 100225
    case FABrandsGlideG = 100313
    case FABrandsGofore = 100117
    case FABrandsGoodreads = 100216
    case FABrandsGoodreadsG = 100171
    case FABrandsGoogle = 100285
    case FABrandsGoogleDrive = 100310
    case FABrandsGooglePlay = 100253
    case FABrandsGooglePlus = 100005
    case FABrandsGooglePlusG = 100294
    case FABrandsGooglePlusSquare = 100051
    case FABrandsGoogleWallet = 100202
    case FABrandsGratipay = 100081
    case FABrandsGrav = 100374
    case FABrandsGripfire = 100344
    case FABrandsGrunt = 100148
    case FABrandsGulp = 100159
    case FABrandsHackerNews = 100400
    case FABrandsHackerNewsSquare = 100088
    case FABrandsHackerrank = 100065
    case FABrandsHips = 100249
    case FABrandsHireAHelper = 100238
    case FABrandsHooli = 100218
    case FABrandsHornbill = 100151
    case FABrandsHotjar = 100044
    case FABrandsHouzz = 100034
    case FABrandsHtml5 = 100064
    case FABrandsHubspot = 100018
    case FABrandsImdb = 100359
    case FABrandsInstagram = 100208
    case FABrandsIntercom = 100078
    case FABrandsInternetExplorer = 100226
    case FABrandsInvision = 100169
    case FABrandsIoxhost = 100273
    case FABrandsItchIo = 100035
    case FABrandsItunes = 100004
    case FABrandsItunesNote = 100061
    case FABrandsJava = 100260
    case FABrandsJediOrder = 100387
    case FABrandsJenkins = 100104
    case FABrandsJira = 100340
    case FABrandsJoget = 100221
    case FABrandsJoomla = 100094
    case FABrandsJs = 100168
    case FABrandsJsSquare = 100155
    case FABrandsJsfiddle = 100293
    case FABrandsKaggle = 100350
    case FABrandsKeybase = 100092
    case FABrandsKeycdn = 100192
    case FABrandsKickstarter = 100336
    case FABrandsKickstarterK = 100385
    case FABrandsKorvue = 100162
    case FABrandsLaravel = 100351
    case FABrandsLastfm = 100019
    case FABrandsLastfmSquare = 100190
    case FABrandsLeanpub = 100188
    case FABrandsLess = 100402
    case FABrandsLine = 100296
    case FABrandsLinkedin = 100391
    case FABrandsLinkedinIn = 100173
    case FABrandsLinode = 100394
    case FABrandsLinux = 100412
    case FABrandsLyft = 100163
    case FABrandsMagento = 100214
    case FABrandsMailchimp = 100397
    case FABrandsMandalorian = 100073
    case FABrandsMarkdown = 100257
    case FABrandsMastodon = 100022
    case FABrandsMaxcdn = 100087
    case FABrandsMdb = 100030
    case FABrandsMedapps = 100138
    case FABrandsMedium = 100097
    case FABrandsMediumM = 100427
    case FABrandsMedrt = 100329
    case FABrandsMeetup = 100077
    case FABrandsMegaport = 100367
    case FABrandsMendeley = 100431
    case FABrandsMicrosoft = 100304
    case FABrandsMix = 100362
    case FABrandsMixcloud = 100317
    case FABrandsMizuni = 100069
    case FABrandsModx = 100183
    case FABrandsMonero = 100334
    case FABrandsNapster = 100197
    case FABrandsNeos = 100185
    case FABrandsNimblr = 100314
    case FABrandsNode = 100106
    case FABrandsNodeJs = 100261
    case FABrandsNpm = 100335
    case FABrandsNs8 = 100295
    case FABrandsNutritionix = 100324
    case FABrandsOdnoklassniki = 100131
    case FABrandsOdnoklassnikiSquare = 100126
    case FABrandsOldRepublic = 100357
    case FABrandsOpencart = 100287
    case FABrandsOpenid = 100204
    case FABrandsOpera = 100136
    case FABrandsOptinMonster = 100178
    case FABrandsOrcid = 100001
    case FABrandsOsi = 100111
    case FABrandsPage4 = 100149
    case FABrandsPagelines = 100333
    case FABrandsPalfed = 100105
    case FABrandsPatreon = 100291
    case FABrandsPaypal = 100098
    case FABrandsPennyArcade = 100354
    case FABrandsPeriscope = 100066
    case FABrandsPhabricator = 100196
    case FABrandsPhoenixFramework = 100369
    case FABrandsPhoenixSquadron = 100010
    case FABrandsPhp = 100399
    case FABrandsPiedPiper = 100375
    case FABrandsPiedPiperAlt = 100416
    case FABrandsPiedPiperHat = 100363
    case FABrandsPiedPiperPp = 100112
    case FABrandsPinterest = 100052
    case FABrandsPinterestP = 100063
    case FABrandsPinterestSquare = 100318
    case FABrandsPlaystation = 100060
    case FABrandsProductHunt = 100056
    case FABrandsPushed = 100213
    case FABrandsPython = 100395
    case FABrandsQq = 100373
    case FABrandsQuinscape = 100232
    case FABrandsQuora = 100311
    case FABrandsRProject = 100368
    case FABrandsRaspberryPi = 100244
    case FABrandsRavelry = 100266
    case FABrandsReact = 100246
    case FABrandsReacteurope = 100290
    case FABrandsReadme = 100256
    case FABrandsRebel = 100140
    case FABrandsRedRiver = 100236
    case FABrandsReddit = 100062
    case FABrandsRedditAlien = 100137
    case FABrandsRedditSquare = 100158
    case FABrandsRedhat = 100143
    case FABrandsRenren = 100380
    case FABrandsReplyd = 100016
    case FABrandsResearchgate = 100425
    case FABrandsResolving = 100303
    case FABrandsRev = 100348
    case FABrandsRocketchat = 100157
    case FABrandsRockrms = 100371
    case FABrandsSafari = 100133
    case FABrandsSalesforce = 100211
    case FABrandsSass = 100432
    case FABrandsSchlix = 100125
    case FABrandsScribd = 100229
    case FABrandsSearchengin = 100186
    case FABrandsSellcast = 100332
    case FABrandsSellsy = 100264
    case FABrandsServicestack = 100153
    case FABrandsShirtsinbulk = 100356
    case FABrandsShopware = 100100
    case FABrandsSimplybuilt = 100286
    case FABrandsSistrix = 100008
    case FABrandsSith = 100389
    case FABrandsSketch = 100284
    case FABrandsSkyatlas = 100407
    case FABrandsSkype = 100268
    case FABrandsSlack = 100358
    case FABrandsSlackHash = 100370
    case FABrandsSlideshare = 100181
    case FABrandsSnapchat = 100345
    case FABrandsSnapchatGhost = 100121
    case FABrandsSnapchatSquare = 100047
    case FABrandsSoundcloud = 100036
    case FABrandsSourcetree = 100360
    case FABrandsSpeakap = 100089
    case FABrandsSpeakerDeck = 100361
    case FABrandsSpotify = 100342
    case FABrandsSquarespace = 100054
    case FABrandsStackExchange = 100272
    case FABrandsStackOverflow = 100281
    case FABrandsStackpath = 100300
    case FABrandsStaylinked = 100129
    case FABrandsSteam = 100059
    case FABrandsSteamSquare = 100011
    case FABrandsSteamSymbol = 100182
    case FABrandsStickerMule = 100042
    case FABrandsStrava = 100406
    case FABrandsStripe = 100039
    case FABrandsStripeS = 100013
    case FABrandsStudiovinari = 100223
    case FABrandsStumbleupon = 100328
    case FABrandsStumbleuponCircle = 100372
    case FABrandsSuperpowers = 100070
    case FABrandsSupple = 100258
    case FABrandsSuse = 100210
    case FABrandsSwift = 100381
    case FABrandsSymfony = 100170
    case FABrandsTeamspeak = 100187
    case FABrandsTelegram = 100277
    case FABrandsTelegramPlane = 100207
    case FABrandsTencentWeibo = 100242
    case FABrandsTheRedYeti = 100134
    case FABrandsThemeco = 100082
    case FABrandsThemeisle = 100265
    case FABrandsThinkPeaks = 100193
    case FABrandsTradeFederation = 100067
    case FABrandsTrello = 100177
    case FABrandsTripadvisor = 100379
    case FABrandsTumblr = 100413
    case FABrandsTumblrSquare = 100420
    case FABrandsTwitch = 100095
    case FABrandsTwitter = 100411
    case FABrandsTwitterSquare = 100057
    case FABrandsTypo3 = 100250
    case FABrandsUber = 100298
    case FABrandsUbuntu = 100315
    case FABrandsUikit = 100316
    case FABrandsUmbraco = 100422
    case FABrandsUniregistry = 100430
    case FABrandsUntappd = 100288
    case FABrandsUps = 100037
    case FABrandsUsb = 100325
    case FABrandsUsps = 100003
    case FABrandsUssunnah = 100292
    case FABrandsVaadin = 100269
    case FABrandsViacoin = 100055
    case FABrandsViadeo = 100283
    case FABrandsViadeoSquare = 100166
    case FABrandsViber = 100033
    case FABrandsVimeo = 100388
    case FABrandsVimeoSquare = 100194
    case FABrandsVimeoV = 100184
    case FABrandsVine = 100255
    case FABrandsVk = 100390
    case FABrandsVnv = 100247
    case FABrandsVuejs = 100032
    case FABrandsWaze = 100198
    case FABrandsWeebly = 100176
    case FABrandsWeibo = 100165
    case FABrandsWeixin = 100132
    case FABrandsWhatsapp = 100083
    case FABrandsWhatsappSquare = 100025
    case FABrandsWhmcs = 100276
    case FABrandsWikipediaW = 100109
    case FABrandsWindows = 100297
    case FABrandsWix = 100323
    case FABrandsWizardsOfTheCoast = 100000
    case FABrandsWolfPackBattalion = 100048
    case FABrandsWordpress = 100096
    case FABrandsWordpressSimple = 100020
    case FABrandsWpbeginner = 100239
    case FABrandsWpexplorer = 100119
    case FABrandsWpforms = 100309
    case FABrandsWpressr = 100093
    case FABrandsXbox = 100084
    case FABrandsXing = 100191
    case FABrandsXingSquare = 100156
    case FABrandsYCombinator = 100330
    case FABrandsYahoo = 100015
    case FABrandsYammer = 100161
    case FABrandsYandex = 100222
    case FABrandsYandexInternational = 100024
    case FABrandsYarn = 100352
    case FABrandsYelp = 100424
    case FABrandsYoast = 100220
    case FABrandsYoutube = 100201
    case FABrandsYoutubeSquare = 100401
    case FABrandsZhihu = 100343
    case FABreadSliceSolid = 400080
    case FABriefcaseMedicalSolid = 400683
    case FABriefcaseSolid = 400047
    case FABroadcastTowerSolid = 400484
    case FABroomSolid = 400796
    case FABrushSolid = 400929
    case FABugSolid = 400940
    case FABuildingRegular = 300078
    case FABuildingSolid = 400477
    case FABullhornSolid = 400773
    case FABullseyeSolid = 400723
    case FABurnSolid = 400546
    case FABusAltSolid = 400177
    case FABusSolid = 400936
    case FABusinessTimeSolid = 400850
    case FACalculatorSolid = 400657
    case FACalendarAltRegular = 300144
    case FACalendarAltSolid = 400899
    case FACalendarCheckRegular = 300136
    case FACalendarCheckSolid = 400831
    case FACalendarDaySolid = 400641
    case FACalendarMinusRegular = 300116
    case FACalendarMinusSolid = 400662
    case FACalendarPlusRegular = 300051
    case FACalendarPlusSolid = 400316
    case FACalendarRegular = 300054
    case FACalendarSolid = 400342
    case FACalendarTimesRegular = 300004
    case FACalendarTimesSolid = 400029
    case FACalendarWeekSolid = 400382
    case FACameraRetroSolid = 400108
    case FACameraSolid = 400767
    case FACampgroundSolid = 400563
    case FACandyCaneSolid = 400698
    case FACannabisSolid = 400436
    case FACapsulesSolid = 400855
    case FACarAltSolid = 400386
    case FACarBatterySolid = 400196
    case FACarCrashSolid = 400123
    case FACarSideSolid = 400575
    case FACarSolid = 400279
    case FACaretDownSolid = 400249
    case FACaretLeftSolid = 400355
    case FACaretRightSolid = 400660
    case FACaretSquareDownRegular = 300113
    case FACaretSquareDownSolid = 400653
    case FACaretSquareLeftRegular = 300120
    case FACaretSquareLeftSolid = 400699
    case FACaretSquareRightRegular = 300013
    case FACaretSquareRightSolid = 400066
    case FACaretSquareUpRegular = 300095
    case FACaretSquareUpSolid = 400564
    case FACaretUpSolid = 400011
    case FACarrotSolid = 400780
    case FACartArrowDownSolid = 400727
    case FACartPlusSolid = 400251
    case FACashRegisterSolid = 400182
    case FACatSolid = 400280
    case FACertificateSolid = 400764
    case FAChairSolid = 400237
    case FAChalkboardSolid = 400881
    case FAChalkboardTeacherSolid = 400628
    case FAChargingStationSolid = 400556
    case FAChartAreaSolid = 400100
    case FAChartBarRegular = 300102
    case FAChartBarSolid = 400602
    case FAChartLineSolid = 400786
    case FAChartPieSolid = 400437
    case FACheckCircleRegular = 300039
    case FACheckCircleSolid = 400246
    case FACheckDoubleSolid = 400548
    case FACheckSolid = 400215
    case FACheckSquareRegular = 300130
    case FACheckSquareSolid = 400785
    case FACheeseSolid = 400323
    case FAChessBishopSolid = 400485
    case FAChessBoardSolid = 400225
    case FAChessKingSolid = 400605
    case FAChessKnightSolid = 400757
    case FAChessPawnSolid = 400155
    case FAChessQueenSolid = 400845
    case FAChessRookSolid = 400106
    case FAChessSolid = 400096
    case FAChevronCircleDownSolid = 400287
    case FAChevronCircleLeftSolid = 400175
    case FAChevronCircleRightSolid = 400002
    case FAChevronCircleUpSolid = 400690
    case FAChevronDownSolid = 400574
    case FAChevronLeftSolid = 400250
    case FAChevronRightSolid = 400706
    case FAChevronUpSolid = 400959
    case FAChildSolid = 400142
    case FAChurchSolid = 400644
    case FACircleNotchSolid = 400931
    case FACircleRegular = 300106
    case FACircleSolid = 400618
    case FACitySolid = 400326
    case FAClinicMedicalSolid = 400820
    case FAClipboardCheckSolid = 400350
    case FAClipboardListSolid = 400744
    case FAClipboardRegular = 300129
    case FAClipboardSolid = 400754
    case FAClockRegular = 300083
    case FAClockSolid = 400505
    case FACloneRegular = 300046
    case FACloneSolid = 400293
    case FAClosedCaptioningRegular = 300050
    case FAClosedCaptioningSolid = 400308
    case FACloudDownloadAltSolid = 400765
    case FACloudMeatballSolid = 400783
    case FACloudMoonRainSolid = 400447
    case FACloudMoonSolid = 400880
    case FACloudRainSolid = 400174
    case FACloudShowersHeavySolid = 400000
    case FACloudSolid = 400762
    case FACloudSunRainSolid = 400591
    case FACloudSunSolid = 400672
    case FACloudUploadAltSolid = 400828
    case FACocktailSolid = 400292
    case FACodeBranchSolid = 400127
    case FACodeSolid = 400735
    case FACoffeeSolid = 400062
    case FACogSolid = 400133
    case FACogsSolid = 400675
    case FACoinsSolid = 400035
    case FAColumnsSolid = 400620
    case FACommentAltRegular = 300072
    case FACommentAltSolid = 400433
    case FACommentDollarSolid = 400670
    case FACommentDotsRegular = 300099
    case FACommentDotsSolid = 400585
    case FACommentMedicalSolid = 400021
    case FACommentRegular = 300141
    case FACommentSlashSolid = 400461
    case FACommentSolid = 400874
    case FACommentsDollarSolid = 400185
    case FACommentsRegular = 300031
    case FACommentsSolid = 400184
    case FACompactDiscSolid = 400083
    case FACompassRegular = 300108
    case FACompassSolid = 400623
    case FACompressArrowsAltSolid = 400443
    case FACompressSolid = 400344
    case FAConciergeBellSolid = 400277
    case FACookieBiteSolid = 400724
    case FACookieSolid = 400572
    case FACopyRegular = 300000
    case FACopySolid = 400001
    case FACopyrightRegular = 300104
    case FACopyrightSolid = 400616
    case FACouchSolid = 400598
    case FACreditCardRegular = 300023
    case FACreditCardSolid = 400132
    case FACropAltSolid = 400005
    case FACropSolid = 400749
    case FACrossSolid = 400893
    case FACrosshairsSolid = 400483
    case FACrowSolid = 400748
    case FACrownSolid = 400179
    case FACrutchSolid = 400654
    case FACubeSolid = 400854
    case FACubesSolid = 400635
    case FACutSolid = 400666
    case FADatabaseSolid = 400086
    case FADeafSolid = 400202
    case FADemocratSolid = 400243
    case FADesktopSolid = 400416
    case FADharmachakraSolid = 400009
    case FADiagnosesSolid = 400261
    case FADiceD20Solid = 400797
    case FADiceD6Solid = 400528
    case FADiceFiveSolid = 400401
    case FADiceFourSolid = 400201
    case FADiceOneSolid = 400547
    case FADiceSixSolid = 400312
    case FADiceSolid = 400356
    case FADiceThreeSolid = 400768
    case FADiceTwoSolid = 400079
    case FADigitalTachographSolid = 400226
    case FADirectionsSolid = 400513
    case FADivideSolid = 400162
    case FADizzyRegular = 300025
    case FADizzySolid = 400147
    case FADnaSolid = 400032
    case FADogSolid = 400102
    case FADollarSignSolid = 400844
    case FADollyFlatbedSolid = 400775
    case FADollySolid = 400550
    case FADonateSolid = 400633
    case FADoorClosedSolid = 400197
    case FADoorOpenSolid = 400448
    case FADotCircleRegular = 300033
    case FADotCircleSolid = 400209
    case FADoveSolid = 400295
    case FADownloadSolid = 400752
    case FADraftingCompassSolid = 400007
    case FADragonSolid = 400541
    case FADrawPolygonSolid = 400758
    case FADrumSolid = 400870
    case FADrumSteelpanSolid = 400089
    case FADrumstickBiteSolid = 400726
    case FADumbbellSolid = 400737
    case FADumpsterFireSolid = 400590
    case FADumpsterSolid = 400815
    case FADungeonSolid = 400863
    case FAEditRegular = 300134
    case FAEditSolid = 400806
    case FAEggSolid = 400545
    case FAEjectSolid = 400848
    case FAEllipsisHSolid = 400466
    case FAEllipsisVSolid = 400561
    case FAEnvelopeOpenRegular = 300131
    case FAEnvelopeOpenSolid = 400787
    case FAEnvelopeOpenTextSolid = 400464
    case FAEnvelopeRegular = 300042
    case FAEnvelopeSolid = 400275
    case FAEnvelopeSquareSolid = 400890
    case FAEqualsSolid = 400027
    case FAEraserSolid = 400882
    case FAEthernetSolid = 400053
    case FAEuroSignSolid = 400604
    case FAExchangeAltSolid = 400180
    case FAExclamationCircleSolid = 400183
    case FAExclamationSolid = 400314
    case FAExclamationTriangleSolid = 400674
    case FAExpandArrowsAltSolid = 400652
    case FAExpandSolid = 400903
    case FAExternalLinkAltSolid = 400421
    case FAExternalLinkSquareAltSolid = 400003
    case FAEyeDropperSolid = 400613
    case FAEyeRegular = 300087
    case FAEyeSlashRegular = 300005
    case FAEyeSlashSolid = 400030
    case FAEyeSolid = 400521
    case FAFanSolid = 400493
    case FAFastBackwardSolid = 400517
    case FAFastForwardSolid = 400140
    case FAFaxSolid = 400490
    case FAFeatherAltSolid = 400031
    case FAFeatherSolid = 400884
    case FAFemaleSolid = 400930
    case FAFighterJetSolid = 400862
    case FAFileAltRegular = 300086
    case FAFileAltSolid = 400512
    case FAFileArchiveRegular = 300047
    case FAFileArchiveSolid = 400294
    case FAFileAudioRegular = 300149
    case FAFileAudioSolid = 400952
    case FAFileCodeRegular = 300030
    case FAFileCodeSolid = 400178
    case FAFileContractSolid = 400871
    case FAFileCsvSolid = 400304
    case FAFileDownloadSolid = 400305
    case FAFileExcelRegular = 300127
    case FAFileExcelSolid = 400732
    case FAFileExportSolid = 400097
    case FAFileImageRegular = 300040
    case FAFileImageSolid = 400262
    case FAFileImportSolid = 400934
    case FAFileInvoiceDollarSolid = 400230
    case FAFileInvoiceSolid = 400028
    case FAFileMedicalAltSolid = 400170
    case FAFileMedicalSolid = 400658
    case FAFilePdfRegular = 300097
    case FAFilePdfSolid = 400569
    case FAFilePowerpointRegular = 300085
    case FAFilePowerpointSolid = 400508
    case FAFilePrescriptionSolid = 400740
    case FAFileRegular = 300077
    case FAFileSignatureSolid = 400455
    case FAFileSolid = 400469
    case FAFileUploadSolid = 400090
    case FAFileVideoRegular = 300061
    case FAFileVideoSolid = 400380
    case FAFileWordRegular = 300132
    case FAFileWordSolid = 400799
    case FAFillDripSolid = 400460
    case FAFillSolid = 400472
    case FAFilmSolid = 400471
    case FAFilterSolid = 400075
    case FAFingerprintSolid = 400909
    case FAFireAltSolid = 400476
    case FAFireExtinguisherSolid = 400611
    case FAFireSolid = 400650
    case FAFirstAidSolid = 400374
    case FAFishSolid = 400562
    case FAFistRaisedSolid = 400204
    case FAFlagCheckeredSolid = 400946
    case FAFlagRegular = 300090
    case FAFlagSolid = 400526
    case FAFlagUsaSolid = 400424
    case FAFlaskSolid = 400516
    case FAFlushedRegular = 300036
    case FAFlushedSolid = 400223
    case FAFolderMinusSolid = 400242
    case FAFolderOpenRegular = 300015
    case FAFolderOpenSolid = 400076
    case FAFolderPlusSolid = 400288
    case FAFolderRegular = 300018
    case FAFolderSolid = 400112
    case FAFontAwesomeLogoFullRegular = 300088
    case FAFontAwesomeLogoFullSolid = 400524
    case FAFontSolid = 400614
    case FAFootballBallSolid = 400935
    case FAForwardSolid = 400332
    case FAFrogSolid = 400766
    case FAFrownOpenRegular = 300117
    case FAFrownOpenSolid = 400665
    case FAFrownRegular = 300067
    case FAFrownSolid = 400422
    case FAFunnelDollarSolid = 400319
    case FAFutbolRegular = 300103
    case FAFutbolSolid = 400607
    case FAGamepadSolid = 400667
    case FAGasPumpSolid = 400912
    case FAGavelSolid = 400697
    case FAGemRegular = 300059
    case FAGemSolid = 400364
    case FAGenderlessSolid = 400400
    case FAGhostSolid = 400955
    case FAGiftSolid = 400173
    case FAGiftsSolid = 400475
    case FAGlassCheersSolid = 400621
    case FAGlassMartiniAltSolid = 400634
    case FAGlassMartiniSolid = 400865
    case FAGlassWhiskeySolid = 400259
    case FAGlassesSolid = 400809
    case FAGlobeAfricaSolid = 400689
    case FAGlobeAmericasSolid = 400719
    case FAGlobeAsiaSolid = 400592
    case FAGlobeEuropeSolid = 400704
    case FAGlobeSolid = 400810
    case FAGolfBallSolid = 400906
    case FAGopuramSolid = 400010
    case FAGraduationCapSolid = 400025
    case FAGreaterThanEqualSolid = 400518
    case FAGreaterThanSolid = 400165
    case FAGrimaceRegular = 300038
    case FAGrimaceSolid = 400245
    case FAGrinAltRegular = 300112
    case FAGrinAltSolid = 400648
    case FAGrinBeamRegular = 300140
    case FAGrinBeamSolid = 400867
    case FAGrinBeamSweatRegular = 300092
    case FAGrinBeamSweatSolid = 400554
    case FAGrinHeartsRegular = 300142
    case FAGrinHeartsSolid = 400886
    case FAGrinRegular = 300068
    case FAGrinSolid = 400425
    case FAGrinSquintRegular = 300049
    case FAGrinSquintSolid = 400307
    case FAGrinSquintTearsRegular = 300148
    case FAGrinSquintTearsSolid = 400947
    case FAGrinStarsRegular = 300128
    case FAGrinStarsSolid = 400745
    case FAGrinTearsRegular = 300091
    case FAGrinTearsSolid = 400551
    case FAGrinTongueRegular = 300093
    case FAGrinTongueSolid = 400557
    case FAGrinTongueSquintRegular = 300056
    case FAGrinTongueSquintSolid = 400352
    case FAGrinTongueWinkRegular = 300075
    case FAGrinTongueWinkSolid = 400449
    case FAGrinWinkRegular = 300107
    case FAGrinWinkSolid = 400622
    case FAGripHorizontalSolid = 400200
    case FAGripLinesSolid = 400206
    case FAGripLinesVerticalSolid = 400876
    case FAGripVerticalSolid = 400811
    case FAGuitarSolid = 400373
    case FAHSquareSolid = 400777
    case FAHamburgerSolid = 400533
    case FAHammerSolid = 400125
    case FAHamsaSolid = 400753
    case FAHandHoldingHeartSolid = 400404
    case FAHandHoldingSolid = 400391
    case FAHandHoldingUsdSolid = 400763
    case FAHandLizardRegular = 300082
    case FAHandLizardSolid = 400504
    case FAHandMiddleFingerSolid = 400875
    case FAHandPaperRegular = 300003
    case FAHandPaperSolid = 400026
    case FAHandPeaceRegular = 300096
    case FAHandPeaceSolid = 400568
    case FAHandPointDownRegular = 300143
    case FAHandPointDownSolid = 400897
    case FAHandPointLeftRegular = 300024
    case FAHandPointLeftSolid = 400145
    case FAHandPointRightRegular = 300012
    case FAHandPointRightSolid = 400063
    case FAHandPointUpRegular = 300151
    case FAHandPointUpSolid = 400960
    case FAHandPointerRegular = 300057
    case FAHandPointerSolid = 400359
    case FAHandRockRegular = 300076
    case FAHandRockSolid = 400458
    case FAHandScissorsRegular = 300037
    case FAHandScissorsSolid = 400229
    case FAHandSpockRegular = 300079
    case FAHandSpockSolid = 400482
    case FAHandsHelpingSolid = 400645
    case FAHandsSolid = 400804
    case FAHandshakeRegular = 300028
    case FAHandshakeSolid = 400163
    case FAHanukiahSolid = 400134
    case FAHardHatSolid = 400917
    case FAHashtagSolid = 400393
    case FAHatCowboySideSolid = 400559
    case FAHatCowboySolid = 400187
    case FAHatWizardSolid = 400341
    case FAHaykalSolid = 400395
    case FAHddRegular = 300064
    case FAHddSolid = 400396
    case FAHeadingSolid = 400018
    case FAHeadphonesAltSolid = 400057
    case FAHeadphonesSolid = 400050
    case FAHeadsetSolid = 400601
    case FAHeartBrokenSolid = 400465
    case FAHeartRegular = 300043
    case FAHeartSolid = 400283
    case FAHeartbeatSolid = 400539
    case FAHelicopterSolid = 400390
    case FAHighlighterSolid = 400891
    case FAHikingSolid = 400264
    case FAHippoSolid = 400361
    case FAHistorySolid = 400532
    case FAHockeyPuckSolid = 400110
    case FAHollyBerrySolid = 400904
    case FAHomeSolid = 400919
    case FAHorseHeadSolid = 400118
    case FAHorseSolid = 400571
    case FAHospitalAltSolid = 400398
    case FAHospitalRegular = 300006
    case FAHospitalSolid = 400034
    case FAHospitalSymbolSolid = 400714
    case FAHotTubSolid = 400686
    case FAHotdogSolid = 400664
    case FAHotelSolid = 400587
    case FAHourglassEndSolid = 400849
    case FAHourglassHalfSolid = 400254
    case FAHourglassRegular = 300019
    case FAHourglassSolid = 400126
    case FAHourglassStartSolid = 400392
    case FAHouseDamageSolid = 400705
    case FAHryvniaSolid = 400522
    case FAICursorSolid = 400278
    case FAIceCreamSolid = 400823
    case FAIciclesSolid = 400107
    case FAIconsSolid = 400486
    case FAIdBadgeRegular = 300053
    case FAIdBadgeSolid = 400338
    case FAIdCardAltSolid = 400784
    case FAIdCardRegular = 300138
    case FAIdCardSolid = 400840
    case FAIglooSolid = 400232
    case FAImageRegular = 300074
    case FAImageSolid = 400445
    case FAImagesRegular = 300124
    case FAImagesSolid = 400716
    case FAInboxSolid = 400450
    case FAIndentSolid = 400816
    case FAIndustrySolid = 400441
    case FAInfinitySolid = 400896
    case FAInfoCircleSolid = 400510
    case FAInfoSolid = 400711
    case FAItalicSolid = 400454
    case FAJediSolid = 400507
    case FAJointSolid = 400858
    case FAJournalWhillsSolid = 400124
    case FAKaabaSolid = 400093
    case FAKeySolid = 400868
    case FAKeyboardRegular = 300011
    case FAKeyboardSolid = 400056
    case FAKhandaSolid = 400808
    case FAKissBeamRegular = 300001
    case FAKissBeamSolid = 400004
    case FAKissRegular = 300133
    case FAKissSolid = 400803
    case FAKissWinkHeartRegular = 300026
    case FAKissWinkHeartSolid = 400148
    case FAKiwiBirdSolid = 400362
    case FALandmarkSolid = 400663
    case FALanguageSolid = 400320
    case FALaptopCodeSolid = 400410
    case FALaptopMedicalSolid = 400016
    case FALaptopSolid = 400158
    case FALaughBeamRegular = 300147
    case FALaughBeamSolid = 400922
    case FALaughRegular = 300069
    case FALaughSolid = 400429
    case FALaughSquintRegular = 300022
    case FALaughSquintSolid = 400131
    case FALaughWinkRegular = 300098
    case FALaughWinkSolid = 400577
    case FALayerGroupSolid = 400276
    case FALeafSolid = 400728
    case FALemonRegular = 300125
    case FALemonSolid = 400718
    case FALessThanEqualSolid = 400679
    case FALessThanSolid = 400847
    case FALevelDownAltSolid = 400302
    case FALevelUpAltSolid = 400821
    case FALifeRingRegular = 300008
    case FALifeRingSolid = 400043
    case FALightbulbRegular = 300146
    case FALightbulbSolid = 400907
    case FALinkSolid = 400709
    case FALiraSignSolid = 400608
    case FAListAltRegular = 300021
    case FAListAltSolid = 400129
    case FAListOlSolid = 400117
    case FAListSolid = 400496
    case FAListUlSolid = 400693
    case FALocationArrowSolid = 400317
    case FALockOpenSolid = 400778
    case FALockSolid = 400779
    case FALongArrowAltDownSolid = 400730
    case FALongArrowAltLeftSolid = 400747
    case FALongArrowAltRightSolid = 400040
    case FALongArrowAltUpSolid = 400756
    case FALowVisionSolid = 400933
    case FALuggageCartSolid = 400440
    case FAMagicSolid = 400555
    case FAMagnetSolid = 400244
    case FAMailBulkSolid = 400095
    case FAMaleSolid = 400531
    case FAMapMarkedAltSolid = 400141
    case FAMapMarkedSolid = 400902
    case FAMapMarkerAltSolid = 400336
    case FAMapMarkerSolid = 400898
    case FAMapPinSolid = 400367
    case FAMapRegular = 300045
    case FAMapSignsSolid = 400370
    case FAMapSolid = 400291
    case FAMarkerSolid = 400268
    case FAMarsDoubleSolid = 400431
    case FAMarsSolid = 400389
    case FAMarsStrokeHSolid = 400859
    case FAMarsStrokeSolid = 400695
    case FAMarsStrokeVSolid = 400856
    case FAMaskSolid = 400480
    case FAMedalSolid = 400846
    case FAMedkitSolid = 400091
    case FAMehBlankRegular = 300055
    case FAMehBlankSolid = 400349
    case FAMehRegular = 300020
    case FAMehRollingEyesRegular = 300137
    case FAMehRollingEyesSolid = 400835
    case FAMehSolid = 400128
    case FAMemorySolid = 400272
    case FAMenorahSolid = 400168
    case FAMercurySolid = 400081
    case FAMeteorSolid = 400950
    case FAMicrochipSolid = 400509
    case FAMicrophoneAltSlashSolid = 400872
    case FAMicrophoneAltSolid = 400782
    case FAMicrophoneSlashSolid = 400542
    case FAMicrophoneSolid = 400838
    case FAMicroscopeSolid = 400121
    case FAMinusCircleSolid = 400154
    case FAMinusSolid = 400092
    case FAMinusSquareRegular = 300118
    case FAMinusSquareSolid = 400669
    case FAMittenSolid = 400104
    case FAMobileAltSolid = 400267
    case FAMobileSolid = 400606
    case FAMoneyBillAltRegular = 300110
    case FAMoneyBillAltSolid = 400627
    case FAMoneyBillSolid = 400573
    case FAMoneyBillWaveAltSolid = 400957
    case FAMoneyBillWaveSolid = 400208
    case FAMoneyCheckAltSolid = 400115
    case FAMoneyCheckSolid = 400135
    case FAMonumentSolid = 400942
    case FAMoonRegular = 300073
    case FAMoonSolid = 400435
    case FAMortarPestleSolid = 400176
    case FAMosqueSolid = 400739
    case FAMotorcycleSolid = 400793
    case FAMountainSolid = 400597
    case FAMousePointerSolid = 400274
    case FAMouseSolid = 400149
    case FAMugHotSolid = 400703
    case FAMusicSolid = 400199
    case FANetworkWiredSolid = 400194
    case FANeuterSolid = 400478
    case FANewspaperRegular = 300065
    case FANewspaperSolid = 400397
    case FANotEqualSolid = 400235
    case FANotesMedicalSolid = 400233
    case FAObjectGroupRegular = 300114
    case FAObjectGroupSolid = 400655
    case FAObjectUngroupRegular = 300009
    case FAObjectUngroupSolid = 400046
    case FAOilCanSolid = 400048
    case FAOmSolid = 400439
    case FAOtterSolid = 400203
    case FAOutdentSolid = 400529
    case FAPagerSolid = 400348
    case FAPaintBrushSolid = 400824
    case FAPaintRollerSolid = 400340
    case FAPaletteSolid = 400371
    case FAPalletSolid = 400417
    case FAPaperPlaneRegular = 300081
    case FAPaperPlaneSolid = 400501
    case FAPaperclipSolid = 400798
    case FAParachuteBoxSolid = 400825
    case FAParagraphSolid = 400530
    case FAParkingSolid = 400369
    case FAPassportSolid = 400036
    case FAPastafarianismSolid = 400938
    case FAPasteSolid = 400924
    case FAPauseCircleRegular = 300071
    case FAPauseCircleSolid = 400432
    case FAPauseSolid = 400257
    case FAPawSolid = 400403
    case FAPeaceSolid = 400720
    case FAPenAltSolid = 400742
    case FAPenFancySolid = 400334
    case FAPenNibSolid = 400408
    case FAPenSolid = 400684
    case FAPenSquareSolid = 400769
    case FAPencilAltSolid = 400143
    case FAPencilRulerSolid = 400637
    case FAPeopleCarrySolid = 400224
    case FAPepperHotSolid = 400588
    case FAPercentSolid = 400948
    case FAPercentageSolid = 400084
    case FAPersonBoothSolid = 400315
    case FAPhoneAltSolid = 400061
    case FAPhoneSlashSolid = 400252
    case FAPhoneSolid = 400039
    case FAPhoneSquareAltSolid = 400794
    case FAPhoneSquareSolid = 400822
    case FAPhoneVolumeSolid = 400894
    case FAPhotoVideoSolid = 400826
    case FAPiggyBankSolid = 400240
    case FAPillsSolid = 400313
    case FAPizzaSliceSolid = 400041
    case FAPlaceOfWorshipSolid = 400851
    case FAPlaneArrivalSolid = 400195
    case FAPlaneDepartureSolid = 400643
    case FAPlaneSolid = 400538
    case FAPlayCircleRegular = 300139
    case FAPlayCircleSolid = 400842
    case FAPlaySolid = 400600
    case FAPlugSolid = 400273
    case FAPlusCircleSolid = 400222
    case FAPlusSolid = 400191
    case FAPlusSquareRegular = 300035
    case FAPlusSquareSolid = 400219
    case FAPodcastSolid = 400459
    case FAPollHSolid = 400914
    case FAPollSolid = 400385
    case FAPooSolid = 400384
    case FAPooStormSolid = 400857
    case FAPoopSolid = 400474
    case FAPortraitSolid = 400629
    case FAPoundSignSolid = 400070
    case FAPowerOffSolid = 400216
    case FAPraySolid = 400549
    case FAPrayingHandsSolid = 400241
    case FAPrescriptionBottleAltSolid = 400956
    case FAPrescriptionBottleSolid = 400905
    case FAPrescriptionSolid = 400636
    case FAPrintSolid = 400492
    case FAProceduresSolid = 400860
    case FAProjectDiagramSolid = 400059
    case FAPuzzlePieceSolid = 400599
    case FAQrcodeSolid = 400581
    case FAQuestionCircleRegular = 300032
    case FAQuestionCircleSolid = 400192
    case FAQuestionSolid = 400702
    case FAQuidditchSolid = 400920
    case FAQuoteLeftSolid = 400266
    case FAQuoteRightSolid = 400138
    case FAQuranSolid = 400318
    case FARadiationAltSolid = 400925
    case FARadiationSolid = 400892
    case FARainbowSolid = 400717
    case FARandomSolid = 400105
    case FAReceiptSolid = 400309
    case FARecordVinylSolid = 400060
    case FARecycleSolid = 400006
    case FARedoAltSolid = 400841
    case FARedoSolid = 400682
    case FARegisteredRegular = 300122
    case FARegisteredSolid = 400707
    case FARemoveFormatSolid = 400843
    case FAReplyAllSolid = 400927
    case FAReplySolid = 400253
    case FARepublicanSolid = 400805
    case FARestroomSolid = 400377
    case FARetweetSolid = 400630
    case FARibbonSolid = 400503
    case FARingSolid = 400325
    case FARoadSolid = 400444
    case FARobotSolid = 400788
    case FARocketSolid = 400908
    case FARouteSolid = 400818
    case FARssSolid = 400113
    case FARssSquareSolid = 400328
    case FARubleSignSolid = 400357
    case FARulerCombinedSolid = 400861
    case FARulerHorizontalSolid = 400339
    case FARulerSolid = 400423
    case FARulerVerticalSolid = 400358
    case FARunningSolid = 400407
    case FARupeeSignSolid = 400068
    case FASadCryRegular = 300126
    case FASadCrySolid = 400731
    case FASadTearRegular = 300094
    case FASadTearSolid = 400560
    case FASatelliteDishSolid = 400953
    case FASatelliteSolid = 400153
    case FASaveRegular = 300029
    case FASaveSolid = 400166
    case FASchoolSolid = 400012
    case FAScrewdriverSolid = 400491
    case FAScrollSolid = 400734
    case FASdCardSolid = 400887
    case FASearchDollarSolid = 400247
    case FASearchLocationSolid = 400659
    case FASearchMinusSolid = 400722
    case FASearchPlusSolid = 400534
    case FASearchSolid = 400514
    case FASeedlingSolid = 400394
    case FAServerSolid = 400426
    case FAShapesSolid = 400677
    case FAShareAltSolid = 400333
    case FAShareAltSquareSolid = 400837
    case FAShareSolid = 400535
    case FAShareSquareRegular = 300121
    case FAShareSquareSolid = 400700
    case FAShekelSignSolid = 400595
    case FAShieldAltSolid = 400941
    case FAShipSolid = 400213
    case FAShippingFastSolid = 400354
    case FAShoePrintsSolid = 400755
    case FAShoppingBagSolid = 400853
    case FAShoppingBasketSolid = 400324
    case FAShoppingCartSolid = 400037
    case FAShowerSolid = 400088
    case FAShuttleVanSolid = 400639
    case FASignInAltSolid = 400830
    case FASignLanguageSolid = 400098
    case FASignOutAltSolid = 400829
    case FASignSolid = 400248
    case FASignalSolid = 400676
    case FASignatureSolid = 400077
    case FASimCardSolid = 400827
    case FASitemapSolid = 400680
    case FASkatingSolid = 400943
    case FASkiingNordicSolid = 400360
    case FASkiingSolid = 400236
    case FASkullCrossbonesSolid = 400411
    case FASkullSolid = 400712
    case FASlashSolid = 400685
    case FASleighSolid = 400678
    case FASlidersHSolid = 400519
    case FASmileBeamRegular = 300044
    case FASmileBeamSolid = 400285
    case FASmileRegular = 300080
    case FASmileSolid = 400489
    case FASmileWinkRegular = 300100
    case FASmileWinkSolid = 400586
    case FASmogSolid = 400812
    case FASmokingBanSolid = 400694
    case FASmokingSolid = 400888
    case FASmsSolid = 400069
    case FASnowboardingSolid = 400576
    case FASnowflakeRegular = 300016
    case FASnowflakeSolid = 400099
    case FASnowmanSolid = 400157
    case FASnowplowSolid = 400932
    case FASocksSolid = 400181
    case FASolarPanelSolid = 400895
    case FASortAlphaDownAltSolid = 400205
    case FASortAlphaDownSolid = 400866
    case FASortAlphaUpAltSolid = 400167
    case FASortAlphaUpSolid = 400303
    case FASortAmountDownAltSolid = 400713
    case FASortAmountDownSolid = 400583
    case FASortAmountUpAltSolid = 400345
    case FASortAmountUpSolid = 400552
    case FASortDownSolid = 400082
    case FASortNumericDownAltSolid = 400836
    case FASortNumericDownSolid = 400649
    case FASortNumericUpAltSolid = 400234
    case FASortNumericUpSolid = 400495
    case FASortSolid = 400770
    case FASortUpSolid = 400330
    case FASpaSolid = 400286
    case FASpaceShuttleSolid = 400366
    case FASpellCheckSolid = 400094
    case FASpiderSolid = 400067
    case FASpinnerSolid = 400911
    case FASplotchSolid = 400211
    case FASprayCanSolid = 400428
    case FASquareFullSolid = 400885
    case FASquareRegular = 300048
    case FASquareRootAltSolid = 400023
    case FASquareSolid = 400306
    case FAStampSolid = 400646
    case FAStarAndCrescentSolid = 400365
    case FAStarHalfAltSolid = 400212
    case FAStarHalfRegular = 300034
    case FAStarHalfSolid = 400210
    case FAStarOfDavidSolid = 400221
    case FAStarOfLifeSolid = 400883
    case FAStarRegular = 300150
    case FAStarSolid = 400954
    case FAStepBackwardSolid = 400051
    case FAStepForwardSolid = 400733
    case FAStethoscopeSolid = 400527
    case FAStickyNoteRegular = 300145
    case FAStickyNoteSolid = 400901
    case FAStopCircleRegular = 300105
    case FAStopCircleSolid = 400617
    case FAStopSolid = 400114
    case FAStopwatchSolid = 400419
    case FAStoreAltSolid = 400729
    case FAStoreSolid = 400584
    case FAStreamSolid = 400284
    case FAStreetViewSolid = 400164
    case FAStrikethroughSolid = 400310
    case FAStroopwafelSolid = 400085
    case FASubscriptSolid = 400632
    case FASubwaySolid = 400570
    case FASuitcaseRollingSolid = 400688
    case FASuitcaseSolid = 400462
    case FASunRegular = 300084
    case FASunSolid = 400506
    case FASuperscriptSolid = 400298
    case FASurpriseRegular = 300014
    case FASurpriseSolid = 400071
    case FASwatchbookSolid = 400156
    case FASwimmerSolid = 400442
    case FASwimmingPoolSolid = 400150
    case FASynagogueSolid = 400402
    case FASyncAltSolid = 400802
    case FASyncSolid = 400500
    case FASyringeSolid = 400451
    case FATableSolid = 400877
    case FATableTennisSolid = 400453
    case FATabletAltSolid = 400553
    case FATabletSolid = 400668
    case FATabletsSolid = 400301
    case FATachometerAltSolid = 400456
    case FATagSolid = 400776
    case FATagsSolid = 400511
    case FATapeSolid = 400852
    case FATasksSolid = 400263
    case FATaxiSolid = 400412
    case FATeethOpenSolid = 400923
    case FATeethSolid = 400228
    case FATemperatureHighSolid = 400523
    case FATemperatureLowSolid = 400928
    case FATengeSolid = 400470
    case FATerminalSolid = 400270
    case FATextHeightSolid = 400578
    case FATextWidthSolid = 400327
    case FAThLargeSolid = 400467
    case FAThListSolid = 400869
    case FAThSolid = 400488
    case FATheaterMasksSolid = 400913
    case FAThermometerEmptySolid = 400673
    case FAThermometerFullSolid = 400537
    case FAThermometerHalfSolid = 400701
    case FAThermometerQuarterSolid = 400691
    case FAThermometerSolid = 400343
    case FAThermometerThreeQuartersSolid = 400721
    case FAThumbsDownRegular = 300017
    case FAThumbsDownSolid = 400109
    case FAThumbsUpRegular = 300063
    case FAThumbsUpSolid = 400387
    case FAThumbtackSolid = 400078
    case FATicketAltSolid = 400289
    case FATimesCircleRegular = 300060
    case FATimesCircleSolid = 400372
    case FATimesSolid = 400819
    case FATintSlashSolid = 400642
    case FATintSolid = 400137
    case FATiredRegular = 300002
    case FATiredSolid = 400020
    case FAToggleOffSolid = 400833
    case FAToggleOnSolid = 400418
    case FAToiletPaperSolid = 400044
    case FAToiletSolid = 400463
    case FAToolboxSolid = 400116
    case FAToolsSolid = 400761
    case FAToothSolid = 400351
    case FATorahSolid = 400159
    case FAToriiGateSolid = 400736
    case FATractorSolid = 400337
    case FATrademarkSolid = 400879
    case FATrafficLightSolid = 400834
    case FATrainSolid = 400772
    case FATramSolid = 400915
    case FATransgenderAltSolid = 400771
    case FATransgenderSolid = 400218
    case FATrashAltRegular = 300119
    case FATrashAltSolid = 400671
    case FATrashRestoreAltSolid = 400024
    case FATrashRestoreSolid = 400916
    case FATrashSolid = 400473
    case FATreeSolid = 400087
    case FATrophySolid = 400190
    case FATruckLoadingSolid = 400013
    case FATruckMonsterSolid = 400609
    case FATruckMovingSolid = 400939
    case FATruckPickupSolid = 400409
    case FATruckSolid = 400297
    case FATshirtSolid = 400889
    case FATtySolid = 400299
    case FATvSolid = 400487
    case FAUmbrellaBeachSolid = 400375
    case FAUmbrellaSolid = 400813
    case FAUnderlineSolid = 400413
    case FAUndoAltSolid = 400789
    case FAUndoSolid = 400814
    case FAUniversalAccessSolid = 400055
    case FAUniversitySolid = 400807
    case FAUnlinkSolid = 400540
    case FAUnlockAltSolid = 400378
    case FAUnlockSolid = 400311
    case FAUploadSolid = 400015
    case FAUserAltSlashSolid = 400119
    case FAUserAltSolid = 400321
    case FAUserAstronautSolid = 400582
    case FAUserCheckSolid = 400136
    case FAUserCircleRegular = 300027
    case FAUserCircleSolid = 400161
    case FAUserClockSolid = 400800
    case FAUserCogSolid = 400130
    case FAUserEditSolid = 400589
    case FAUserFriendsSolid = 400169
    case FAUserGraduateSolid = 400383
    case FAUserInjuredSolid = 400008
    case FAUserLockSolid = 400160
    case FAUserMdSolid = 400791
    case FAUserMinusSolid = 400198
    case FAUserNinjaSolid = 400331
    case FAUserNurseSolid = 400781
    case FAUserPlusSolid = 400543
    case FAUserRegular = 300115
    case FAUserSecretSolid = 400379
    case FAUserShieldSolid = 400759
    case FAUserSlashSolid = 400399
    case FAUserSolid = 400661
    case FAUserTagSolid = 400120
    case FAUserTieSolid = 400269
    case FAUserTimesSolid = 400146
    case FAUsersCogSolid = 400651
    case FAUsersSolid = 400725
    case FAUtensilSpoonSolid = 400434
    case FAUtensilsSolid = 400945
    case FAVectorSquareSolid = 400265
    case FAVenusDoubleSolid = 400481
    case FAVenusMarsSolid = 400944
    case FAVenusSolid = 400017
    case FAVialSolid = 400593
    case FAVialsSolid = 400388
    case FAVideoSlashSolid = 400072
    case FAVideoSolid = 400751
    case FAViharaSolid = 400746
    case FAVoicemailSolid = 400376
    case FAVolleyballBallSolid = 400502
    case FAVolumeDownSolid = 400696
    case FAVolumeMuteSolid = 400579
    case FAVolumeOffSolid = 400558
    case FAVolumeUpSolid = 400743
    case FAVoteYeaSolid = 400580
    case FAVrCardboardSolid = 400152
    case FAWalkingSolid = 400353
    case FAWalletSolid = 400281
    case FAWarehouseSolid = 400217
    case FAWaterSolid = 400256
    case FAWaveSquareSolid = 400603
    case FAWeightHangingSolid = 400151
    case FAWeightSolid = 400452
    case FAWheelchairSolid = 400296
    case FAWifiSolid = 400479
    case FAWindSolid = 400054
    case FAWindowCloseRegular = 300123
    case FAWindowCloseSolid = 400708
    case FAWindowMaximizeRegular = 300010
    case FAWindowMaximizeSolid = 400049
    case FAWindowMinimizeRegular = 300070
    case FAWindowMinimizeSolid = 400430
    case FAWindowRestoreRegular = 300089
    case FAWindowRestoreSolid = 400525
    case FAWineBottleSolid = 400073
    case FAWineGlassAltSolid = 400258
    case FAWineGlassSolid = 400624
    case FAWonSignSolid = 400790
    case FAWrenchSolid = 400544
    case FAXRaySolid = 400715
    case FAYenSignSolid = 400864
    case FAYinYangSolid = 400619

    func string() -> String {
        let icons = [
            FAIcon.FAAdSolid: "\u{f641}",
            FAIcon.FAAddressBookRegular: "\u{f2b9}",
            FAIcon.FAAddressBookSolid: "\u{f2b9}",
            FAIcon.FAAddressCardRegular: "\u{f2bb}",
            FAIcon.FAAddressCardSolid: "\u{f2bb}",
            FAIcon.FAAdjustSolid: "\u{f042}",
            FAIcon.FAAirFreshenerSolid: "\u{f5d0}",
            FAIcon.FAAlignCenterSolid: "\u{f037}",
            FAIcon.FAAlignJustifySolid: "\u{f039}",
            FAIcon.FAAlignLeftSolid: "\u{f036}",
            FAIcon.FAAlignRightSolid: "\u{f038}",
            FAIcon.FAAllergiesSolid: "\u{f461}",
            FAIcon.FAAmbulanceSolid: "\u{f0f9}",
            FAIcon.FAAmericanSignLanguageInterpretingSolid: "\u{f2a3}",
            FAIcon.FAAnchorSolid: "\u{f13d}",
            FAIcon.FAAngleDoubleDownSolid: "\u{f103}",
            FAIcon.FAAngleDoubleLeftSolid: "\u{f100}",
            FAIcon.FAAngleDoubleRightSolid: "\u{f101}",
            FAIcon.FAAngleDoubleUpSolid: "\u{f102}",
            FAIcon.FAAngleDownSolid: "\u{f107}",
            FAIcon.FAAngleLeftSolid: "\u{f104}",
            FAIcon.FAAngleRightSolid: "\u{f105}",
            FAIcon.FAAngleUpSolid: "\u{f106}",
            FAIcon.FAAngryRegular: "\u{f556}",
            FAIcon.FAAngrySolid: "\u{f556}",
            FAIcon.FAAnkhSolid: "\u{f644}",
            FAIcon.FAAppleAltSolid: "\u{f5d1}",
            FAIcon.FAArchiveSolid: "\u{f187}",
            FAIcon.FAArchwaySolid: "\u{f557}",
            FAIcon.FAArrowAltCircleDownRegular: "\u{f358}",
            FAIcon.FAArrowAltCircleDownSolid: "\u{f358}",
            FAIcon.FAArrowAltCircleLeftRegular: "\u{f359}",
            FAIcon.FAArrowAltCircleLeftSolid: "\u{f359}",
            FAIcon.FAArrowAltCircleRightRegular: "\u{f35a}",
            FAIcon.FAArrowAltCircleRightSolid: "\u{f35a}",
            FAIcon.FAArrowAltCircleUpRegular: "\u{f35b}",
            FAIcon.FAArrowAltCircleUpSolid: "\u{f35b}",
            FAIcon.FAArrowCircleDownSolid: "\u{f0ab}",
            FAIcon.FAArrowCircleLeftSolid: "\u{f0a8}",
            FAIcon.FAArrowCircleRightSolid: "\u{f0a9}",
            FAIcon.FAArrowCircleUpSolid: "\u{f0aa}",
            FAIcon.FAArrowDownSolid: "\u{f063}",
            FAIcon.FAArrowLeftSolid: "\u{f060}",
            FAIcon.FAArrowRightSolid: "\u{f061}",
            FAIcon.FAArrowUpSolid: "\u{f062}",
            FAIcon.FAArrowsAltHSolid: "\u{f337}",
            FAIcon.FAArrowsAltSolid: "\u{f0b2}",
            FAIcon.FAArrowsAltVSolid: "\u{f338}",
            FAIcon.FAAssistiveListeningSystemsSolid: "\u{f2a2}",
            FAIcon.FAAsteriskSolid: "\u{f069}",
            FAIcon.FAAtSolid: "\u{f1fa}",
            FAIcon.FAAtlasSolid: "\u{f558}",
            FAIcon.FAAtomSolid: "\u{f5d2}",
            FAIcon.FAAudioDescriptionSolid: "\u{f29e}",
            FAIcon.FAAwardSolid: "\u{f559}",
            FAIcon.FABabyCarriageSolid: "\u{f77d}",
            FAIcon.FABabySolid: "\u{f77c}",
            FAIcon.FABackspaceSolid: "\u{f55a}",
            FAIcon.FABackwardSolid: "\u{f04a}",
            FAIcon.FABaconSolid: "\u{f7e5}",
            FAIcon.FABalanceScaleLeftSolid: "\u{f515}",
            FAIcon.FABalanceScaleRightSolid: "\u{f516}",
            FAIcon.FABalanceScaleSolid: "\u{f24e}",
            FAIcon.FABanSolid: "\u{f05e}",
            FAIcon.FABandAidSolid: "\u{f462}",
            FAIcon.FABarcodeSolid: "\u{f02a}",
            FAIcon.FABarsSolid: "\u{f0c9}",
            FAIcon.FABaseballBallSolid: "\u{f433}",
            FAIcon.FABasketballBallSolid: "\u{f434}",
            FAIcon.FABathSolid: "\u{f2cd}",
            FAIcon.FABatteryEmptySolid: "\u{f244}",
            FAIcon.FABatteryFullSolid: "\u{f240}",
            FAIcon.FABatteryHalfSolid: "\u{f242}",
            FAIcon.FABatteryQuarterSolid: "\u{f243}",
            FAIcon.FABatteryThreeQuartersSolid: "\u{f241}",
            FAIcon.FABedSolid: "\u{f236}",
            FAIcon.FABeerSolid: "\u{f0fc}",
            FAIcon.FABellRegular: "\u{f0f3}",
            FAIcon.FABellSlashRegular: "\u{f1f6}",
            FAIcon.FABellSlashSolid: "\u{f1f6}",
            FAIcon.FABellSolid: "\u{f0f3}",
            FAIcon.FABezierCurveSolid: "\u{f55b}",
            FAIcon.FABibleSolid: "\u{f647}",
            FAIcon.FABicycleSolid: "\u{f206}",
            FAIcon.FABikingSolid: "\u{f84a}",
            FAIcon.FABinocularsSolid: "\u{f1e5}",
            FAIcon.FABiohazardSolid: "\u{f780}",
            FAIcon.FABirthdayCakeSolid: "\u{f1fd}",
            FAIcon.FABlenderPhoneSolid: "\u{f6b6}",
            FAIcon.FABlenderSolid: "\u{f517}",
            FAIcon.FABlindSolid: "\u{f29d}",
            FAIcon.FABlogSolid: "\u{f781}",
            FAIcon.FABoldSolid: "\u{f032}",
            FAIcon.FABoltSolid: "\u{f0e7}",
            FAIcon.FABombSolid: "\u{f1e2}",
            FAIcon.FABoneSolid: "\u{f5d7}",
            FAIcon.FABongSolid: "\u{f55c}",
            FAIcon.FABookDeadSolid: "\u{f6b7}",
            FAIcon.FABookMedicalSolid: "\u{f7e6}",
            FAIcon.FABookOpenSolid: "\u{f518}",
            FAIcon.FABookReaderSolid: "\u{f5da}",
            FAIcon.FABookSolid: "\u{f02d}",
            FAIcon.FABookmarkRegular: "\u{f02e}",
            FAIcon.FABookmarkSolid: "\u{f02e}",
            FAIcon.FABorderAllSolid: "\u{f84c}",
            FAIcon.FABorderNoneSolid: "\u{f850}",
            FAIcon.FABorderStyleSolid: "\u{f853}",
            FAIcon.FABowlingBallSolid: "\u{f436}",
            FAIcon.FABoxOpenSolid: "\u{f49e}",
            FAIcon.FABoxSolid: "\u{f466}",
            FAIcon.FABoxesSolid: "\u{f468}",
            FAIcon.FABrailleSolid: "\u{f2a1}",
            FAIcon.FABrainSolid: "\u{f5dc}",
            FAIcon.FABrands500px: "\u{f26e}",
            FAIcon.FABrandsAccessibleIcon: "\u{f368}",
            FAIcon.FABrandsAccusoft: "\u{f369}",
            FAIcon.FABrandsAcquisitionsIncorporated: "\u{f6af}",
            FAIcon.FABrandsAdn: "\u{f170}",
            FAIcon.FABrandsAdobe: "\u{f778}",
            FAIcon.FABrandsAdversal: "\u{f36a}",
            FAIcon.FABrandsAffiliatetheme: "\u{f36b}",
            FAIcon.FABrandsAirbnb: "\u{f834}",
            FAIcon.FABrandsAlgolia: "\u{f36c}",
            FAIcon.FABrandsAlipay: "\u{f642}",
            FAIcon.FABrandsAmazon: "\u{f270}",
            FAIcon.FABrandsAmazonPay: "\u{f42c}",
            FAIcon.FABrandsAmilia: "\u{f36d}",
            FAIcon.FABrandsAndroid: "\u{f17b}",
            FAIcon.FABrandsAngellist: "\u{f209}",
            FAIcon.FABrandsAngrycreative: "\u{f36e}",
            FAIcon.FABrandsAngular: "\u{f420}",
            FAIcon.FABrandsAppStore: "\u{f36f}",
            FAIcon.FABrandsAppStoreIos: "\u{f370}",
            FAIcon.FABrandsApper: "\u{f371}",
            FAIcon.FABrandsApple: "\u{f179}",
            FAIcon.FABrandsApplePay: "\u{f415}",
            FAIcon.FABrandsArtstation: "\u{f77a}",
            FAIcon.FABrandsAsymmetrik: "\u{f372}",
            FAIcon.FABrandsAtlassian: "\u{f77b}",
            FAIcon.FABrandsAudible: "\u{f373}",
            FAIcon.FABrandsAutoprefixer: "\u{f41c}",
            FAIcon.FABrandsAvianex: "\u{f374}",
            FAIcon.FABrandsAviato: "\u{f421}",
            FAIcon.FABrandsAws: "\u{f375}",
            FAIcon.FABrandsBandcamp: "\u{f2d5}",
            FAIcon.FABrandsBattleNet: "\u{f835}",
            FAIcon.FABrandsBehance: "\u{f1b4}",
            FAIcon.FABrandsBehanceSquare: "\u{f1b5}",
            FAIcon.FABrandsBimobject: "\u{f378}",
            FAIcon.FABrandsBitbucket: "\u{f171}",
            FAIcon.FABrandsBitcoin: "\u{f379}",
            FAIcon.FABrandsBity: "\u{f37a}",
            FAIcon.FABrandsBlackTie: "\u{f27e}",
            FAIcon.FABrandsBlackberry: "\u{f37b}",
            FAIcon.FABrandsBlogger: "\u{f37c}",
            FAIcon.FABrandsBloggerB: "\u{f37d}",
            FAIcon.FABrandsBluetooth: "\u{f293}",
            FAIcon.FABrandsBluetoothB: "\u{f294}",
            FAIcon.FABrandsBootstrap: "\u{f836}",
            FAIcon.FABrandsBtc: "\u{f15a}",
            FAIcon.FABrandsBuffer: "\u{f837}",
            FAIcon.FABrandsBuromobelexperte: "\u{f37f}",
            FAIcon.FABrandsBuyNLarge: "\u{f8a6}",
            FAIcon.FABrandsBuysellads: "\u{f20d}",
            FAIcon.FABrandsCanadianMapleLeaf: "\u{f785}",
            FAIcon.FABrandsCcAmazonPay: "\u{f42d}",
            FAIcon.FABrandsCcAmex: "\u{f1f3}",
            FAIcon.FABrandsCcApplePay: "\u{f416}",
            FAIcon.FABrandsCcDinersClub: "\u{f24c}",
            FAIcon.FABrandsCcDiscover: "\u{f1f2}",
            FAIcon.FABrandsCcJcb: "\u{f24b}",
            FAIcon.FABrandsCcMastercard: "\u{f1f1}",
            FAIcon.FABrandsCcPaypal: "\u{f1f4}",
            FAIcon.FABrandsCcStripe: "\u{f1f5}",
            FAIcon.FABrandsCcVisa: "\u{f1f0}",
            FAIcon.FABrandsCentercode: "\u{f380}",
            FAIcon.FABrandsCentos: "\u{f789}",
            FAIcon.FABrandsChrome: "\u{f268}",
            FAIcon.FABrandsChromecast: "\u{f838}",
            FAIcon.FABrandsCloudscale: "\u{f383}",
            FAIcon.FABrandsCloudsmith: "\u{f384}",
            FAIcon.FABrandsCloudversify: "\u{f385}",
            FAIcon.FABrandsCodepen: "\u{f1cb}",
            FAIcon.FABrandsCodiepie: "\u{f284}",
            FAIcon.FABrandsConfluence: "\u{f78d}",
            FAIcon.FABrandsConnectdevelop: "\u{f20e}",
            FAIcon.FABrandsContao: "\u{f26d}",
            FAIcon.FABrandsCottonBureau: "\u{f89e}",
            FAIcon.FABrandsCpanel: "\u{f388}",
            FAIcon.FABrandsCreativeCommons: "\u{f25e}",
            FAIcon.FABrandsCreativeCommonsBy: "\u{f4e7}",
            FAIcon.FABrandsCreativeCommonsNc: "\u{f4e8}",
            FAIcon.FABrandsCreativeCommonsNcEu: "\u{f4e9}",
            FAIcon.FABrandsCreativeCommonsNcJp: "\u{f4ea}",
            FAIcon.FABrandsCreativeCommonsNd: "\u{f4eb}",
            FAIcon.FABrandsCreativeCommonsPd: "\u{f4ec}",
            FAIcon.FABrandsCreativeCommonsPdAlt: "\u{f4ed}",
            FAIcon.FABrandsCreativeCommonsRemix: "\u{f4ee}",
            FAIcon.FABrandsCreativeCommonsSa: "\u{f4ef}",
            FAIcon.FABrandsCreativeCommonsSampling: "\u{f4f0}",
            FAIcon.FABrandsCreativeCommonsSamplingPlus: "\u{f4f1}",
            FAIcon.FABrandsCreativeCommonsShare: "\u{f4f2}",
            FAIcon.FABrandsCreativeCommonsZero: "\u{f4f3}",
            FAIcon.FABrandsCriticalRole: "\u{f6c9}",
            FAIcon.FABrandsCss3: "\u{f13c}",
            FAIcon.FABrandsCss3Alt: "\u{f38b}",
            FAIcon.FABrandsCuttlefish: "\u{f38c}",
            FAIcon.FABrandsDAndD: "\u{f38d}",
            FAIcon.FABrandsDAndDBeyond: "\u{f6ca}",
            FAIcon.FABrandsDashcube: "\u{f210}",
            FAIcon.FABrandsDelicious: "\u{f1a5}",
            FAIcon.FABrandsDeploydog: "\u{f38e}",
            FAIcon.FABrandsDeskpro: "\u{f38f}",
            FAIcon.FABrandsDev: "\u{f6cc}",
            FAIcon.FABrandsDeviantart: "\u{f1bd}",
            FAIcon.FABrandsDhl: "\u{f790}",
            FAIcon.FABrandsDiaspora: "\u{f791}",
            FAIcon.FABrandsDigg: "\u{f1a6}",
            FAIcon.FABrandsDigitalOcean: "\u{f391}",
            FAIcon.FABrandsDiscord: "\u{f392}",
            FAIcon.FABrandsDiscourse: "\u{f393}",
            FAIcon.FABrandsDochub: "\u{f394}",
            FAIcon.FABrandsDocker: "\u{f395}",
            FAIcon.FABrandsDraft2digital: "\u{f396}",
            FAIcon.FABrandsDribbble: "\u{f17d}",
            FAIcon.FABrandsDribbbleSquare: "\u{f397}",
            FAIcon.FABrandsDropbox: "\u{f16b}",
            FAIcon.FABrandsDrupal: "\u{f1a9}",
            FAIcon.FABrandsDyalog: "\u{f399}",
            FAIcon.FABrandsEarlybirds: "\u{f39a}",
            FAIcon.FABrandsEbay: "\u{f4f4}",
            FAIcon.FABrandsEdge: "\u{f282}",
            FAIcon.FABrandsElementor: "\u{f430}",
            FAIcon.FABrandsEllo: "\u{f5f1}",
            FAIcon.FABrandsEmber: "\u{f423}",
            FAIcon.FABrandsEmpire: "\u{f1d1}",
            FAIcon.FABrandsEnvira: "\u{f299}",
            FAIcon.FABrandsErlang: "\u{f39d}",
            FAIcon.FABrandsEthereum: "\u{f42e}",
            FAIcon.FABrandsEtsy: "\u{f2d7}",
            FAIcon.FABrandsEvernote: "\u{f839}",
            FAIcon.FABrandsExpeditedssl: "\u{f23e}",
            FAIcon.FABrandsFacebook: "\u{f09a}",
            FAIcon.FABrandsFacebookF: "\u{f39e}",
            FAIcon.FABrandsFacebookMessenger: "\u{f39f}",
            FAIcon.FABrandsFacebookSquare: "\u{f082}",
            FAIcon.FABrandsFantasyFlightGames: "\u{f6dc}",
            FAIcon.FABrandsFedex: "\u{f797}",
            FAIcon.FABrandsFedora: "\u{f798}",
            FAIcon.FABrandsFigma: "\u{f799}",
            FAIcon.FABrandsFirefox: "\u{f269}",
            FAIcon.FABrandsFirstOrder: "\u{f2b0}",
            FAIcon.FABrandsFirstOrderAlt: "\u{f50a}",
            FAIcon.FABrandsFirstdraft: "\u{f3a1}",
            FAIcon.FABrandsFlickr: "\u{f16e}",
            FAIcon.FABrandsFlipboard: "\u{f44d}",
            FAIcon.FABrandsFly: "\u{f417}",
            FAIcon.FABrandsFontAwesome: "\u{f2b4}",
            FAIcon.FABrandsFontAwesomeAlt: "\u{f35c}",
            FAIcon.FABrandsFontAwesomeFlag: "\u{f425}",
            FAIcon.FABrandsFonticons: "\u{f280}",
            FAIcon.FABrandsFonticonsFi: "\u{f3a2}",
            FAIcon.FABrandsFortAwesome: "\u{f286}",
            FAIcon.FABrandsFortAwesomeAlt: "\u{f3a3}",
            FAIcon.FABrandsForumbee: "\u{f211}",
            FAIcon.FABrandsFoursquare: "\u{f180}",
            FAIcon.FABrandsFreeCodeCamp: "\u{f2c5}",
            FAIcon.FABrandsFreebsd: "\u{f3a4}",
            FAIcon.FABrandsFulcrum: "\u{f50b}",
            FAIcon.FABrandsGalacticRepublic: "\u{f50c}",
            FAIcon.FABrandsGalacticSenate: "\u{f50d}",
            FAIcon.FABrandsGetPocket: "\u{f265}",
            FAIcon.FABrandsGg: "\u{f260}",
            FAIcon.FABrandsGgCircle: "\u{f261}",
            FAIcon.FABrandsGit: "\u{f1d3}",
            FAIcon.FABrandsGitAlt: "\u{f841}",
            FAIcon.FABrandsGitSquare: "\u{f1d2}",
            FAIcon.FABrandsGithub: "\u{f09b}",
            FAIcon.FABrandsGithubAlt: "\u{f113}",
            FAIcon.FABrandsGithubSquare: "\u{f092}",
            FAIcon.FABrandsGitkraken: "\u{f3a6}",
            FAIcon.FABrandsGitlab: "\u{f296}",
            FAIcon.FABrandsGitter: "\u{f426}",
            FAIcon.FABrandsGlide: "\u{f2a5}",
            FAIcon.FABrandsGlideG: "\u{f2a6}",
            FAIcon.FABrandsGofore: "\u{f3a7}",
            FAIcon.FABrandsGoodreads: "\u{f3a8}",
            FAIcon.FABrandsGoodreadsG: "\u{f3a9}",
            FAIcon.FABrandsGoogle: "\u{f1a0}",
            FAIcon.FABrandsGoogleDrive: "\u{f3aa}",
            FAIcon.FABrandsGooglePlay: "\u{f3ab}",
            FAIcon.FABrandsGooglePlus: "\u{f2b3}",
            FAIcon.FABrandsGooglePlusG: "\u{f0d5}",
            FAIcon.FABrandsGooglePlusSquare: "\u{f0d4}",
            FAIcon.FABrandsGoogleWallet: "\u{f1ee}",
            FAIcon.FABrandsGratipay: "\u{f184}",
            FAIcon.FABrandsGrav: "\u{f2d6}",
            FAIcon.FABrandsGripfire: "\u{f3ac}",
            FAIcon.FABrandsGrunt: "\u{f3ad}",
            FAIcon.FABrandsGulp: "\u{f3ae}",
            FAIcon.FABrandsHackerNews: "\u{f1d4}",
            FAIcon.FABrandsHackerNewsSquare: "\u{f3af}",
            FAIcon.FABrandsHackerrank: "\u{f5f7}",
            FAIcon.FABrandsHips: "\u{f452}",
            FAIcon.FABrandsHireAHelper: "\u{f3b0}",
            FAIcon.FABrandsHooli: "\u{f427}",
            FAIcon.FABrandsHornbill: "\u{f592}",
            FAIcon.FABrandsHotjar: "\u{f3b1}",
            FAIcon.FABrandsHouzz: "\u{f27c}",
            FAIcon.FABrandsHtml5: "\u{f13b}",
            FAIcon.FABrandsHubspot: "\u{f3b2}",
            FAIcon.FABrandsImdb: "\u{f2d8}",
            FAIcon.FABrandsInstagram: "\u{f16d}",
            FAIcon.FABrandsIntercom: "\u{f7af}",
            FAIcon.FABrandsInternetExplorer: "\u{f26b}",
            FAIcon.FABrandsInvision: "\u{f7b0}",
            FAIcon.FABrandsIoxhost: "\u{f208}",
            FAIcon.FABrandsItchIo: "\u{f83a}",
            FAIcon.FABrandsItunes: "\u{f3b4}",
            FAIcon.FABrandsItunesNote: "\u{f3b5}",
            FAIcon.FABrandsJava: "\u{f4e4}",
            FAIcon.FABrandsJediOrder: "\u{f50e}",
            FAIcon.FABrandsJenkins: "\u{f3b6}",
            FAIcon.FABrandsJira: "\u{f7b1}",
            FAIcon.FABrandsJoget: "\u{f3b7}",
            FAIcon.FABrandsJoomla: "\u{f1aa}",
            FAIcon.FABrandsJs: "\u{f3b8}",
            FAIcon.FABrandsJsSquare: "\u{f3b9}",
            FAIcon.FABrandsJsfiddle: "\u{f1cc}",
            FAIcon.FABrandsKaggle: "\u{f5fa}",
            FAIcon.FABrandsKeybase: "\u{f4f5}",
            FAIcon.FABrandsKeycdn: "\u{f3ba}",
            FAIcon.FABrandsKickstarter: "\u{f3bb}",
            FAIcon.FABrandsKickstarterK: "\u{f3bc}",
            FAIcon.FABrandsKorvue: "\u{f42f}",
            FAIcon.FABrandsLaravel: "\u{f3bd}",
            FAIcon.FABrandsLastfm: "\u{f202}",
            FAIcon.FABrandsLastfmSquare: "\u{f203}",
            FAIcon.FABrandsLeanpub: "\u{f212}",
            FAIcon.FABrandsLess: "\u{f41d}",
            FAIcon.FABrandsLine: "\u{f3c0}",
            FAIcon.FABrandsLinkedin: "\u{f08c}",
            FAIcon.FABrandsLinkedinIn: "\u{f0e1}",
            FAIcon.FABrandsLinode: "\u{f2b8}",
            FAIcon.FABrandsLinux: "\u{f17c}",
            FAIcon.FABrandsLyft: "\u{f3c3}",
            FAIcon.FABrandsMagento: "\u{f3c4}",
            FAIcon.FABrandsMailchimp: "\u{f59e}",
            FAIcon.FABrandsMandalorian: "\u{f50f}",
            FAIcon.FABrandsMarkdown: "\u{f60f}",
            FAIcon.FABrandsMastodon: "\u{f4f6}",
            FAIcon.FABrandsMaxcdn: "\u{f136}",
            FAIcon.FABrandsMdb: "\u{f8ca}",
            FAIcon.FABrandsMedapps: "\u{f3c6}",
            FAIcon.FABrandsMedium: "\u{f23a}",
            FAIcon.FABrandsMediumM: "\u{f3c7}",
            FAIcon.FABrandsMedrt: "\u{f3c8}",
            FAIcon.FABrandsMeetup: "\u{f2e0}",
            FAIcon.FABrandsMegaport: "\u{f5a3}",
            FAIcon.FABrandsMendeley: "\u{f7b3}",
            FAIcon.FABrandsMicrosoft: "\u{f3ca}",
            FAIcon.FABrandsMix: "\u{f3cb}",
            FAIcon.FABrandsMixcloud: "\u{f289}",
            FAIcon.FABrandsMizuni: "\u{f3cc}",
            FAIcon.FABrandsModx: "\u{f285}",
            FAIcon.FABrandsMonero: "\u{f3d0}",
            FAIcon.FABrandsNapster: "\u{f3d2}",
            FAIcon.FABrandsNeos: "\u{f612}",
            FAIcon.FABrandsNimblr: "\u{f5a8}",
            FAIcon.FABrandsNode: "\u{f419}",
            FAIcon.FABrandsNodeJs: "\u{f3d3}",
            FAIcon.FABrandsNpm: "\u{f3d4}",
            FAIcon.FABrandsNs8: "\u{f3d5}",
            FAIcon.FABrandsNutritionix: "\u{f3d6}",
            FAIcon.FABrandsOdnoklassniki: "\u{f263}",
            FAIcon.FABrandsOdnoklassnikiSquare: "\u{f264}",
            FAIcon.FABrandsOldRepublic: "\u{f510}",
            FAIcon.FABrandsOpencart: "\u{f23d}",
            FAIcon.FABrandsOpenid: "\u{f19b}",
            FAIcon.FABrandsOpera: "\u{f26a}",
            FAIcon.FABrandsOptinMonster: "\u{f23c}",
            FAIcon.FABrandsOrcid: "\u{f8d2}",
            FAIcon.FABrandsOsi: "\u{f41a}",
            FAIcon.FABrandsPage4: "\u{f3d7}",
            FAIcon.FABrandsPagelines: "\u{f18c}",
            FAIcon.FABrandsPalfed: "\u{f3d8}",
            FAIcon.FABrandsPatreon: "\u{f3d9}",
            FAIcon.FABrandsPaypal: "\u{f1ed}",
            FAIcon.FABrandsPennyArcade: "\u{f704}",
            FAIcon.FABrandsPeriscope: "\u{f3da}",
            FAIcon.FABrandsPhabricator: "\u{f3db}",
            FAIcon.FABrandsPhoenixFramework: "\u{f3dc}",
            FAIcon.FABrandsPhoenixSquadron: "\u{f511}",
            FAIcon.FABrandsPhp: "\u{f457}",
            FAIcon.FABrandsPiedPiper: "\u{f2ae}",
            FAIcon.FABrandsPiedPiperAlt: "\u{f1a8}",
            FAIcon.FABrandsPiedPiperHat: "\u{f4e5}",
            FAIcon.FABrandsPiedPiperPp: "\u{f1a7}",
            FAIcon.FABrandsPinterest: "\u{f0d2}",
            FAIcon.FABrandsPinterestP: "\u{f231}",
            FAIcon.FABrandsPinterestSquare: "\u{f0d3}",
            FAIcon.FABrandsPlaystation: "\u{f3df}",
            FAIcon.FABrandsProductHunt: "\u{f288}",
            FAIcon.FABrandsPushed: "\u{f3e1}",
            FAIcon.FABrandsPython: "\u{f3e2}",
            FAIcon.FABrandsQq: "\u{f1d6}",
            FAIcon.FABrandsQuinscape: "\u{f459}",
            FAIcon.FABrandsQuora: "\u{f2c4}",
            FAIcon.FABrandsRProject: "\u{f4f7}",
            FAIcon.FABrandsRaspberryPi: "\u{f7bb}",
            FAIcon.FABrandsRavelry: "\u{f2d9}",
            FAIcon.FABrandsReact: "\u{f41b}",
            FAIcon.FABrandsReacteurope: "\u{f75d}",
            FAIcon.FABrandsReadme: "\u{f4d5}",
            FAIcon.FABrandsRebel: "\u{f1d0}",
            FAIcon.FABrandsRedRiver: "\u{f3e3}",
            FAIcon.FABrandsReddit: "\u{f1a1}",
            FAIcon.FABrandsRedditAlien: "\u{f281}",
            FAIcon.FABrandsRedditSquare: "\u{f1a2}",
            FAIcon.FABrandsRedhat: "\u{f7bc}",
            FAIcon.FABrandsRenren: "\u{f18b}",
            FAIcon.FABrandsReplyd: "\u{f3e6}",
            FAIcon.FABrandsResearchgate: "\u{f4f8}",
            FAIcon.FABrandsResolving: "\u{f3e7}",
            FAIcon.FABrandsRev: "\u{f5b2}",
            FAIcon.FABrandsRocketchat: "\u{f3e8}",
            FAIcon.FABrandsRockrms: "\u{f3e9}",
            FAIcon.FABrandsSafari: "\u{f267}",
            FAIcon.FABrandsSalesforce: "\u{f83b}",
            FAIcon.FABrandsSass: "\u{f41e}",
            FAIcon.FABrandsSchlix: "\u{f3ea}",
            FAIcon.FABrandsScribd: "\u{f28a}",
            FAIcon.FABrandsSearchengin: "\u{f3eb}",
            FAIcon.FABrandsSellcast: "\u{f2da}",
            FAIcon.FABrandsSellsy: "\u{f213}",
            FAIcon.FABrandsServicestack: "\u{f3ec}",
            FAIcon.FABrandsShirtsinbulk: "\u{f214}",
            FAIcon.FABrandsShopware: "\u{f5b5}",
            FAIcon.FABrandsSimplybuilt: "\u{f215}",
            FAIcon.FABrandsSistrix: "\u{f3ee}",
            FAIcon.FABrandsSith: "\u{f512}",
            FAIcon.FABrandsSketch: "\u{f7c6}",
            FAIcon.FABrandsSkyatlas: "\u{f216}",
            FAIcon.FABrandsSkype: "\u{f17e}",
            FAIcon.FABrandsSlack: "\u{f198}",
            FAIcon.FABrandsSlackHash: "\u{f3ef}",
            FAIcon.FABrandsSlideshare: "\u{f1e7}",
            FAIcon.FABrandsSnapchat: "\u{f2ab}",
            FAIcon.FABrandsSnapchatGhost: "\u{f2ac}",
            FAIcon.FABrandsSnapchatSquare: "\u{f2ad}",
            FAIcon.FABrandsSoundcloud: "\u{f1be}",
            FAIcon.FABrandsSourcetree: "\u{f7d3}",
            FAIcon.FABrandsSpeakap: "\u{f3f3}",
            FAIcon.FABrandsSpeakerDeck: "\u{f83c}",
            FAIcon.FABrandsSpotify: "\u{f1bc}",
            FAIcon.FABrandsSquarespace: "\u{f5be}",
            FAIcon.FABrandsStackExchange: "\u{f18d}",
            FAIcon.FABrandsStackOverflow: "\u{f16c}",
            FAIcon.FABrandsStackpath: "\u{f842}",
            FAIcon.FABrandsStaylinked: "\u{f3f5}",
            FAIcon.FABrandsSteam: "\u{f1b6}",
            FAIcon.FABrandsSteamSquare: "\u{f1b7}",
            FAIcon.FABrandsSteamSymbol: "\u{f3f6}",
            FAIcon.FABrandsStickerMule: "\u{f3f7}",
            FAIcon.FABrandsStrava: "\u{f428}",
            FAIcon.FABrandsStripe: "\u{f429}",
            FAIcon.FABrandsStripeS: "\u{f42a}",
            FAIcon.FABrandsStudiovinari: "\u{f3f8}",
            FAIcon.FABrandsStumbleupon: "\u{f1a4}",
            FAIcon.FABrandsStumbleuponCircle: "\u{f1a3}",
            FAIcon.FABrandsSuperpowers: "\u{f2dd}",
            FAIcon.FABrandsSupple: "\u{f3f9}",
            FAIcon.FABrandsSuse: "\u{f7d6}",
            FAIcon.FABrandsSwift: "\u{f8e1}",
            FAIcon.FABrandsSymfony: "\u{f83d}",
            FAIcon.FABrandsTeamspeak: "\u{f4f9}",
            FAIcon.FABrandsTelegram: "\u{f2c6}",
            FAIcon.FABrandsTelegramPlane: "\u{f3fe}",
            FAIcon.FABrandsTencentWeibo: "\u{f1d5}",
            FAIcon.FABrandsTheRedYeti: "\u{f69d}",
            FAIcon.FABrandsThemeco: "\u{f5c6}",
            FAIcon.FABrandsThemeisle: "\u{f2b2}",
            FAIcon.FABrandsThinkPeaks: "\u{f731}",
            FAIcon.FABrandsTradeFederation: "\u{f513}",
            FAIcon.FABrandsTrello: "\u{f181}",
            FAIcon.FABrandsTripadvisor: "\u{f262}",
            FAIcon.FABrandsTumblr: "\u{f173}",
            FAIcon.FABrandsTumblrSquare: "\u{f174}",
            FAIcon.FABrandsTwitch: "\u{f1e8}",
            FAIcon.FABrandsTwitter: "\u{f099}",
            FAIcon.FABrandsTwitterSquare: "\u{f081}",
            FAIcon.FABrandsTypo3: "\u{f42b}",
            FAIcon.FABrandsUber: "\u{f402}",
            FAIcon.FABrandsUbuntu: "\u{f7df}",
            FAIcon.FABrandsUikit: "\u{f403}",
            FAIcon.FABrandsUmbraco: "\u{f8e8}",
            FAIcon.FABrandsUniregistry: "\u{f404}",
            FAIcon.FABrandsUntappd: "\u{f405}",
            FAIcon.FABrandsUps: "\u{f7e0}",
            FAIcon.FABrandsUsb: "\u{f287}",
            FAIcon.FABrandsUsps: "\u{f7e1}",
            FAIcon.FABrandsUssunnah: "\u{f407}",
            FAIcon.FABrandsVaadin: "\u{f408}",
            FAIcon.FABrandsViacoin: "\u{f237}",
            FAIcon.FABrandsViadeo: "\u{f2a9}",
            FAIcon.FABrandsViadeoSquare: "\u{f2aa}",
            FAIcon.FABrandsViber: "\u{f409}",
            FAIcon.FABrandsVimeo: "\u{f40a}",
            FAIcon.FABrandsVimeoSquare: "\u{f194}",
            FAIcon.FABrandsVimeoV: "\u{f27d}",
            FAIcon.FABrandsVine: "\u{f1ca}",
            FAIcon.FABrandsVk: "\u{f189}",
            FAIcon.FABrandsVnv: "\u{f40b}",
            FAIcon.FABrandsVuejs: "\u{f41f}",
            FAIcon.FABrandsWaze: "\u{f83f}",
            FAIcon.FABrandsWeebly: "\u{f5cc}",
            FAIcon.FABrandsWeibo: "\u{f18a}",
            FAIcon.FABrandsWeixin: "\u{f1d7}",
            FAIcon.FABrandsWhatsapp: "\u{f232}",
            FAIcon.FABrandsWhatsappSquare: "\u{f40c}",
            FAIcon.FABrandsWhmcs: "\u{f40d}",
            FAIcon.FABrandsWikipediaW: "\u{f266}",
            FAIcon.FABrandsWindows: "\u{f17a}",
            FAIcon.FABrandsWix: "\u{f5cf}",
            FAIcon.FABrandsWizardsOfTheCoast: "\u{f730}",
            FAIcon.FABrandsWolfPackBattalion: "\u{f514}",
            FAIcon.FABrandsWordpress: "\u{f19a}",
            FAIcon.FABrandsWordpressSimple: "\u{f411}",
            FAIcon.FABrandsWpbeginner: "\u{f297}",
            FAIcon.FABrandsWpexplorer: "\u{f2de}",
            FAIcon.FABrandsWpforms: "\u{f298}",
            FAIcon.FABrandsWpressr: "\u{f3e4}",
            FAIcon.FABrandsXbox: "\u{f412}",
            FAIcon.FABrandsXing: "\u{f168}",
            FAIcon.FABrandsXingSquare: "\u{f169}",
            FAIcon.FABrandsYCombinator: "\u{f23b}",
            FAIcon.FABrandsYahoo: "\u{f19e}",
            FAIcon.FABrandsYammer: "\u{f840}",
            FAIcon.FABrandsYandex: "\u{f413}",
            FAIcon.FABrandsYandexInternational: "\u{f414}",
            FAIcon.FABrandsYarn: "\u{f7e3}",
            FAIcon.FABrandsYelp: "\u{f1e9}",
            FAIcon.FABrandsYoast: "\u{f2b1}",
            FAIcon.FABrandsYoutube: "\u{f167}",
            FAIcon.FABrandsYoutubeSquare: "\u{f431}",
            FAIcon.FABrandsZhihu: "\u{f63f}",
            FAIcon.FABreadSliceSolid: "\u{f7ec}",
            FAIcon.FABriefcaseMedicalSolid: "\u{f469}",
            FAIcon.FABriefcaseSolid: "\u{f0b1}",
            FAIcon.FABroadcastTowerSolid: "\u{f519}",
            FAIcon.FABroomSolid: "\u{f51a}",
            FAIcon.FABrushSolid: "\u{f55d}",
            FAIcon.FABugSolid: "\u{f188}",
            FAIcon.FABuildingRegular: "\u{f1ad}",
            FAIcon.FABuildingSolid: "\u{f1ad}",
            FAIcon.FABullhornSolid: "\u{f0a1}",
            FAIcon.FABullseyeSolid: "\u{f140}",
            FAIcon.FABurnSolid: "\u{f46a}",
            FAIcon.FABusAltSolid: "\u{f55e}",
            FAIcon.FABusSolid: "\u{f207}",
            FAIcon.FABusinessTimeSolid: "\u{f64a}",
            FAIcon.FACalculatorSolid: "\u{f1ec}",
            FAIcon.FACalendarAltRegular: "\u{f073}",
            FAIcon.FACalendarAltSolid: "\u{f073}",
            FAIcon.FACalendarCheckRegular: "\u{f274}",
            FAIcon.FACalendarCheckSolid: "\u{f274}",
            FAIcon.FACalendarDaySolid: "\u{f783}",
            FAIcon.FACalendarMinusRegular: "\u{f272}",
            FAIcon.FACalendarMinusSolid: "\u{f272}",
            FAIcon.FACalendarPlusRegular: "\u{f271}",
            FAIcon.FACalendarPlusSolid: "\u{f271}",
            FAIcon.FACalendarRegular: "\u{f133}",
            FAIcon.FACalendarSolid: "\u{f133}",
            FAIcon.FACalendarTimesRegular: "\u{f273}",
            FAIcon.FACalendarTimesSolid: "\u{f273}",
            FAIcon.FACalendarWeekSolid: "\u{f784}",
            FAIcon.FACameraRetroSolid: "\u{f083}",
            FAIcon.FACameraSolid: "\u{f030}",
            FAIcon.FACampgroundSolid: "\u{f6bb}",
            FAIcon.FACandyCaneSolid: "\u{f786}",
            FAIcon.FACannabisSolid: "\u{f55f}",
            FAIcon.FACapsulesSolid: "\u{f46b}",
            FAIcon.FACarAltSolid: "\u{f5de}",
            FAIcon.FACarBatterySolid: "\u{f5df}",
            FAIcon.FACarCrashSolid: "\u{f5e1}",
            FAIcon.FACarSideSolid: "\u{f5e4}",
            FAIcon.FACarSolid: "\u{f1b9}",
            FAIcon.FACaretDownSolid: "\u{f0d7}",
            FAIcon.FACaretLeftSolid: "\u{f0d9}",
            FAIcon.FACaretRightSolid: "\u{f0da}",
            FAIcon.FACaretSquareDownRegular: "\u{f150}",
            FAIcon.FACaretSquareDownSolid: "\u{f150}",
            FAIcon.FACaretSquareLeftRegular: "\u{f191}",
            FAIcon.FACaretSquareLeftSolid: "\u{f191}",
            FAIcon.FACaretSquareRightRegular: "\u{f152}",
            FAIcon.FACaretSquareRightSolid: "\u{f152}",
            FAIcon.FACaretSquareUpRegular: "\u{f151}",
            FAIcon.FACaretSquareUpSolid: "\u{f151}",
            FAIcon.FACaretUpSolid: "\u{f0d8}",
            FAIcon.FACarrotSolid: "\u{f787}",
            FAIcon.FACartArrowDownSolid: "\u{f218}",
            FAIcon.FACartPlusSolid: "\u{f217}",
            FAIcon.FACashRegisterSolid: "\u{f788}",
            FAIcon.FACatSolid: "\u{f6be}",
            FAIcon.FACertificateSolid: "\u{f0a3}",
            FAIcon.FAChairSolid: "\u{f6c0}",
            FAIcon.FAChalkboardSolid: "\u{f51b}",
            FAIcon.FAChalkboardTeacherSolid: "\u{f51c}",
            FAIcon.FAChargingStationSolid: "\u{f5e7}",
            FAIcon.FAChartAreaSolid: "\u{f1fe}",
            FAIcon.FAChartBarRegular: "\u{f080}",
            FAIcon.FAChartBarSolid: "\u{f080}",
            FAIcon.FAChartLineSolid: "\u{f201}",
            FAIcon.FAChartPieSolid: "\u{f200}",
            FAIcon.FACheckCircleRegular: "\u{f058}",
            FAIcon.FACheckCircleSolid: "\u{f058}",
            FAIcon.FACheckDoubleSolid: "\u{f560}",
            FAIcon.FACheckSolid: "\u{f00c}",
            FAIcon.FACheckSquareRegular: "\u{f14a}",
            FAIcon.FACheckSquareSolid: "\u{f14a}",
            FAIcon.FACheeseSolid: "\u{f7ef}",
            FAIcon.FAChessBishopSolid: "\u{f43a}",
            FAIcon.FAChessBoardSolid: "\u{f43c}",
            FAIcon.FAChessKingSolid: "\u{f43f}",
            FAIcon.FAChessKnightSolid: "\u{f441}",
            FAIcon.FAChessPawnSolid: "\u{f443}",
            FAIcon.FAChessQueenSolid: "\u{f445}",
            FAIcon.FAChessRookSolid: "\u{f447}",
            FAIcon.FAChessSolid: "\u{f439}",
            FAIcon.FAChevronCircleDownSolid: "\u{f13a}",
            FAIcon.FAChevronCircleLeftSolid: "\u{f137}",
            FAIcon.FAChevronCircleRightSolid: "\u{f138}",
            FAIcon.FAChevronCircleUpSolid: "\u{f139}",
            FAIcon.FAChevronDownSolid: "\u{f078}",
            FAIcon.FAChevronLeftSolid: "\u{f053}",
            FAIcon.FAChevronRightSolid: "\u{f054}",
            FAIcon.FAChevronUpSolid: "\u{f077}",
            FAIcon.FAChildSolid: "\u{f1ae}",
            FAIcon.FAChurchSolid: "\u{f51d}",
            FAIcon.FACircleNotchSolid: "\u{f1ce}",
            FAIcon.FACircleRegular: "\u{f111}",
            FAIcon.FACircleSolid: "\u{f111}",
            FAIcon.FACitySolid: "\u{f64f}",
            FAIcon.FAClinicMedicalSolid: "\u{f7f2}",
            FAIcon.FAClipboardCheckSolid: "\u{f46c}",
            FAIcon.FAClipboardListSolid: "\u{f46d}",
            FAIcon.FAClipboardRegular: "\u{f328}",
            FAIcon.FAClipboardSolid: "\u{f328}",
            FAIcon.FAClockRegular: "\u{f017}",
            FAIcon.FAClockSolid: "\u{f017}",
            FAIcon.FACloneRegular: "\u{f24d}",
            FAIcon.FACloneSolid: "\u{f24d}",
            FAIcon.FAClosedCaptioningRegular: "\u{f20a}",
            FAIcon.FAClosedCaptioningSolid: "\u{f20a}",
            FAIcon.FACloudDownloadAltSolid: "\u{f381}",
            FAIcon.FACloudMeatballSolid: "\u{f73b}",
            FAIcon.FACloudMoonRainSolid: "\u{f73c}",
            FAIcon.FACloudMoonSolid: "\u{f6c3}",
            FAIcon.FACloudRainSolid: "\u{f73d}",
            FAIcon.FACloudShowersHeavySolid: "\u{f740}",
            FAIcon.FACloudSolid: "\u{f0c2}",
            FAIcon.FACloudSunRainSolid: "\u{f743}",
            FAIcon.FACloudSunSolid: "\u{f6c4}",
            FAIcon.FACloudUploadAltSolid: "\u{f382}",
            FAIcon.FACocktailSolid: "\u{f561}",
            FAIcon.FACodeBranchSolid: "\u{f126}",
            FAIcon.FACodeSolid: "\u{f121}",
            FAIcon.FACoffeeSolid: "\u{f0f4}",
            FAIcon.FACogSolid: "\u{f013}",
            FAIcon.FACogsSolid: "\u{f085}",
            FAIcon.FACoinsSolid: "\u{f51e}",
            FAIcon.FAColumnsSolid: "\u{f0db}",
            FAIcon.FACommentAltRegular: "\u{f27a}",
            FAIcon.FACommentAltSolid: "\u{f27a}",
            FAIcon.FACommentDollarSolid: "\u{f651}",
            FAIcon.FACommentDotsRegular: "\u{f4ad}",
            FAIcon.FACommentDotsSolid: "\u{f4ad}",
            FAIcon.FACommentMedicalSolid: "\u{f7f5}",
            FAIcon.FACommentRegular: "\u{f075}",
            FAIcon.FACommentSlashSolid: "\u{f4b3}",
            FAIcon.FACommentSolid: "\u{f075}",
            FAIcon.FACommentsDollarSolid: "\u{f653}",
            FAIcon.FACommentsRegular: "\u{f086}",
            FAIcon.FACommentsSolid: "\u{f086}",
            FAIcon.FACompactDiscSolid: "\u{f51f}",
            FAIcon.FACompassRegular: "\u{f14e}",
            FAIcon.FACompassSolid: "\u{f14e}",
            FAIcon.FACompressArrowsAltSolid: "\u{f78c}",
            FAIcon.FACompressSolid: "\u{f066}",
            FAIcon.FAConciergeBellSolid: "\u{f562}",
            FAIcon.FACookieBiteSolid: "\u{f564}",
            FAIcon.FACookieSolid: "\u{f563}",
            FAIcon.FACopyRegular: "\u{f0c5}",
            FAIcon.FACopySolid: "\u{f0c5}",
            FAIcon.FACopyrightRegular: "\u{f1f9}",
            FAIcon.FACopyrightSolid: "\u{f1f9}",
            FAIcon.FACouchSolid: "\u{f4b8}",
            FAIcon.FACreditCardRegular: "\u{f09d}",
            FAIcon.FACreditCardSolid: "\u{f09d}",
            FAIcon.FACropAltSolid: "\u{f565}",
            FAIcon.FACropSolid: "\u{f125}",
            FAIcon.FACrossSolid: "\u{f654}",
            FAIcon.FACrosshairsSolid: "\u{f05b}",
            FAIcon.FACrowSolid: "\u{f520}",
            FAIcon.FACrownSolid: "\u{f521}",
            FAIcon.FACrutchSolid: "\u{f7f7}",
            FAIcon.FACubeSolid: "\u{f1b2}",
            FAIcon.FACubesSolid: "\u{f1b3}",
            FAIcon.FACutSolid: "\u{f0c4}",
            FAIcon.FADatabaseSolid: "\u{f1c0}",
            FAIcon.FADeafSolid: "\u{f2a4}",
            FAIcon.FADemocratSolid: "\u{f747}",
            FAIcon.FADesktopSolid: "\u{f108}",
            FAIcon.FADharmachakraSolid: "\u{f655}",
            FAIcon.FADiagnosesSolid: "\u{f470}",
            FAIcon.FADiceD20Solid: "\u{f6cf}",
            FAIcon.FADiceD6Solid: "\u{f6d1}",
            FAIcon.FADiceFiveSolid: "\u{f523}",
            FAIcon.FADiceFourSolid: "\u{f524}",
            FAIcon.FADiceOneSolid: "\u{f525}",
            FAIcon.FADiceSixSolid: "\u{f526}",
            FAIcon.FADiceSolid: "\u{f522}",
            FAIcon.FADiceThreeSolid: "\u{f527}",
            FAIcon.FADiceTwoSolid: "\u{f528}",
            FAIcon.FADigitalTachographSolid: "\u{f566}",
            FAIcon.FADirectionsSolid: "\u{f5eb}",
            FAIcon.FADivideSolid: "\u{f529}",
            FAIcon.FADizzyRegular: "\u{f567}",
            FAIcon.FADizzySolid: "\u{f567}",
            FAIcon.FADnaSolid: "\u{f471}",
            FAIcon.FADogSolid: "\u{f6d3}",
            FAIcon.FADollarSignSolid: "\u{f155}",
            FAIcon.FADollyFlatbedSolid: "\u{f474}",
            FAIcon.FADollySolid: "\u{f472}",
            FAIcon.FADonateSolid: "\u{f4b9}",
            FAIcon.FADoorClosedSolid: "\u{f52a}",
            FAIcon.FADoorOpenSolid: "\u{f52b}",
            FAIcon.FADotCircleRegular: "\u{f192}",
            FAIcon.FADotCircleSolid: "\u{f192}",
            FAIcon.FADoveSolid: "\u{f4ba}",
            FAIcon.FADownloadSolid: "\u{f019}",
            FAIcon.FADraftingCompassSolid: "\u{f568}",
            FAIcon.FADragonSolid: "\u{f6d5}",
            FAIcon.FADrawPolygonSolid: "\u{f5ee}",
            FAIcon.FADrumSolid: "\u{f569}",
            FAIcon.FADrumSteelpanSolid: "\u{f56a}",
            FAIcon.FADrumstickBiteSolid: "\u{f6d7}",
            FAIcon.FADumbbellSolid: "\u{f44b}",
            FAIcon.FADumpsterFireSolid: "\u{f794}",
            FAIcon.FADumpsterSolid: "\u{f793}",
            FAIcon.FADungeonSolid: "\u{f6d9}",
            FAIcon.FAEditRegular: "\u{f044}",
            FAIcon.FAEditSolid: "\u{f044}",
            FAIcon.FAEggSolid: "\u{f7fb}",
            FAIcon.FAEjectSolid: "\u{f052}",
            FAIcon.FAEllipsisHSolid: "\u{f141}",
            FAIcon.FAEllipsisVSolid: "\u{f142}",
            FAIcon.FAEnvelopeOpenRegular: "\u{f2b6}",
            FAIcon.FAEnvelopeOpenSolid: "\u{f2b6}",
            FAIcon.FAEnvelopeOpenTextSolid: "\u{f658}",
            FAIcon.FAEnvelopeRegular: "\u{f0e0}",
            FAIcon.FAEnvelopeSolid: "\u{f0e0}",
            FAIcon.FAEnvelopeSquareSolid: "\u{f199}",
            FAIcon.FAEqualsSolid: "\u{f52c}",
            FAIcon.FAEraserSolid: "\u{f12d}",
            FAIcon.FAEthernetSolid: "\u{f796}",
            FAIcon.FAEuroSignSolid: "\u{f153}",
            FAIcon.FAExchangeAltSolid: "\u{f362}",
            FAIcon.FAExclamationCircleSolid: "\u{f06a}",
            FAIcon.FAExclamationSolid: "\u{f12a}",
            FAIcon.FAExclamationTriangleSolid: "\u{f071}",
            FAIcon.FAExpandArrowsAltSolid: "\u{f31e}",
            FAIcon.FAExpandSolid: "\u{f065}",
            FAIcon.FAExternalLinkAltSolid: "\u{f35d}",
            FAIcon.FAExternalLinkSquareAltSolid: "\u{f360}",
            FAIcon.FAEyeDropperSolid: "\u{f1fb}",
            FAIcon.FAEyeRegular: "\u{f06e}",
            FAIcon.FAEyeSlashRegular: "\u{f070}",
            FAIcon.FAEyeSlashSolid: "\u{f070}",
            FAIcon.FAEyeSolid: "\u{f06e}",
            FAIcon.FAFanSolid: "\u{f863}",
            FAIcon.FAFastBackwardSolid: "\u{f049}",
            FAIcon.FAFastForwardSolid: "\u{f050}",
            FAIcon.FAFaxSolid: "\u{f1ac}",
            FAIcon.FAFeatherAltSolid: "\u{f56b}",
            FAIcon.FAFeatherSolid: "\u{f52d}",
            FAIcon.FAFemaleSolid: "\u{f182}",
            FAIcon.FAFighterJetSolid: "\u{f0fb}",
            FAIcon.FAFileAltRegular: "\u{f15c}",
            FAIcon.FAFileAltSolid: "\u{f15c}",
            FAIcon.FAFileArchiveRegular: "\u{f1c6}",
            FAIcon.FAFileArchiveSolid: "\u{f1c6}",
            FAIcon.FAFileAudioRegular: "\u{f1c7}",
            FAIcon.FAFileAudioSolid: "\u{f1c7}",
            FAIcon.FAFileCodeRegular: "\u{f1c9}",
            FAIcon.FAFileCodeSolid: "\u{f1c9}",
            FAIcon.FAFileContractSolid: "\u{f56c}",
            FAIcon.FAFileCsvSolid: "\u{f6dd}",
            FAIcon.FAFileDownloadSolid: "\u{f56d}",
            FAIcon.FAFileExcelRegular: "\u{f1c3}",
            FAIcon.FAFileExcelSolid: "\u{f1c3}",
            FAIcon.FAFileExportSolid: "\u{f56e}",
            FAIcon.FAFileImageRegular: "\u{f1c5}",
            FAIcon.FAFileImageSolid: "\u{f1c5}",
            FAIcon.FAFileImportSolid: "\u{f56f}",
            FAIcon.FAFileInvoiceDollarSolid: "\u{f571}",
            FAIcon.FAFileInvoiceSolid: "\u{f570}",
            FAIcon.FAFileMedicalAltSolid: "\u{f478}",
            FAIcon.FAFileMedicalSolid: "\u{f477}",
            FAIcon.FAFilePdfRegular: "\u{f1c1}",
            FAIcon.FAFilePdfSolid: "\u{f1c1}",
            FAIcon.FAFilePowerpointRegular: "\u{f1c4}",
            FAIcon.FAFilePowerpointSolid: "\u{f1c4}",
            FAIcon.FAFilePrescriptionSolid: "\u{f572}",
            FAIcon.FAFileRegular: "\u{f15b}",
            FAIcon.FAFileSignatureSolid: "\u{f573}",
            FAIcon.FAFileSolid: "\u{f15b}",
            FAIcon.FAFileUploadSolid: "\u{f574}",
            FAIcon.FAFileVideoRegular: "\u{f1c8}",
            FAIcon.FAFileVideoSolid: "\u{f1c8}",
            FAIcon.FAFileWordRegular: "\u{f1c2}",
            FAIcon.FAFileWordSolid: "\u{f1c2}",
            FAIcon.FAFillDripSolid: "\u{f576}",
            FAIcon.FAFillSolid: "\u{f575}",
            FAIcon.FAFilmSolid: "\u{f008}",
            FAIcon.FAFilterSolid: "\u{f0b0}",
            FAIcon.FAFingerprintSolid: "\u{f577}",
            FAIcon.FAFireAltSolid: "\u{f7e4}",
            FAIcon.FAFireExtinguisherSolid: "\u{f134}",
            FAIcon.FAFireSolid: "\u{f06d}",
            FAIcon.FAFirstAidSolid: "\u{f479}",
            FAIcon.FAFishSolid: "\u{f578}",
            FAIcon.FAFistRaisedSolid: "\u{f6de}",
            FAIcon.FAFlagCheckeredSolid: "\u{f11e}",
            FAIcon.FAFlagRegular: "\u{f024}",
            FAIcon.FAFlagSolid: "\u{f024}",
            FAIcon.FAFlagUsaSolid: "\u{f74d}",
            FAIcon.FAFlaskSolid: "\u{f0c3}",
            FAIcon.FAFlushedRegular: "\u{f579}",
            FAIcon.FAFlushedSolid: "\u{f579}",
            FAIcon.FAFolderMinusSolid: "\u{f65d}",
            FAIcon.FAFolderOpenRegular: "\u{f07c}",
            FAIcon.FAFolderOpenSolid: "\u{f07c}",
            FAIcon.FAFolderPlusSolid: "\u{f65e}",
            FAIcon.FAFolderRegular: "\u{f07b}",
            FAIcon.FAFolderSolid: "\u{f07b}",
            FAIcon.FAFontAwesomeLogoFullRegular: "\u{f4e6}",
            FAIcon.FAFontAwesomeLogoFullSolid: "\u{f4e6}",
            FAIcon.FAFontSolid: "\u{f031}",
            FAIcon.FAFootballBallSolid: "\u{f44e}",
            FAIcon.FAForwardSolid: "\u{f04e}",
            FAIcon.FAFrogSolid: "\u{f52e}",
            FAIcon.FAFrownOpenRegular: "\u{f57a}",
            FAIcon.FAFrownOpenSolid: "\u{f57a}",
            FAIcon.FAFrownRegular: "\u{f119}",
            FAIcon.FAFrownSolid: "\u{f119}",
            FAIcon.FAFunnelDollarSolid: "\u{f662}",
            FAIcon.FAFutbolRegular: "\u{f1e3}",
            FAIcon.FAFutbolSolid: "\u{f1e3}",
            FAIcon.FAGamepadSolid: "\u{f11b}",
            FAIcon.FAGasPumpSolid: "\u{f52f}",
            FAIcon.FAGavelSolid: "\u{f0e3}",
            FAIcon.FAGemRegular: "\u{f3a5}",
            FAIcon.FAGemSolid: "\u{f3a5}",
            FAIcon.FAGenderlessSolid: "\u{f22d}",
            FAIcon.FAGhostSolid: "\u{f6e2}",
            FAIcon.FAGiftSolid: "\u{f06b}",
            FAIcon.FAGiftsSolid: "\u{f79c}",
            FAIcon.FAGlassCheersSolid: "\u{f79f}",
            FAIcon.FAGlassMartiniAltSolid: "\u{f57b}",
            FAIcon.FAGlassMartiniSolid: "\u{f000}",
            FAIcon.FAGlassWhiskeySolid: "\u{f7a0}",
            FAIcon.FAGlassesSolid: "\u{f530}",
            FAIcon.FAGlobeAfricaSolid: "\u{f57c}",
            FAIcon.FAGlobeAmericasSolid: "\u{f57d}",
            FAIcon.FAGlobeAsiaSolid: "\u{f57e}",
            FAIcon.FAGlobeEuropeSolid: "\u{f7a2}",
            FAIcon.FAGlobeSolid: "\u{f0ac}",
            FAIcon.FAGolfBallSolid: "\u{f450}",
            FAIcon.FAGopuramSolid: "\u{f664}",
            FAIcon.FAGraduationCapSolid: "\u{f19d}",
            FAIcon.FAGreaterThanEqualSolid: "\u{f532}",
            FAIcon.FAGreaterThanSolid: "\u{f531}",
            FAIcon.FAGrimaceRegular: "\u{f57f}",
            FAIcon.FAGrimaceSolid: "\u{f57f}",
            FAIcon.FAGrinAltRegular: "\u{f581}",
            FAIcon.FAGrinAltSolid: "\u{f581}",
            FAIcon.FAGrinBeamRegular: "\u{f582}",
            FAIcon.FAGrinBeamSolid: "\u{f582}",
            FAIcon.FAGrinBeamSweatRegular: "\u{f583}",
            FAIcon.FAGrinBeamSweatSolid: "\u{f583}",
            FAIcon.FAGrinHeartsRegular: "\u{f584}",
            FAIcon.FAGrinHeartsSolid: "\u{f584}",
            FAIcon.FAGrinRegular: "\u{f580}",
            FAIcon.FAGrinSolid: "\u{f580}",
            FAIcon.FAGrinSquintRegular: "\u{f585}",
            FAIcon.FAGrinSquintSolid: "\u{f585}",
            FAIcon.FAGrinSquintTearsRegular: "\u{f586}",
            FAIcon.FAGrinSquintTearsSolid: "\u{f586}",
            FAIcon.FAGrinStarsRegular: "\u{f587}",
            FAIcon.FAGrinStarsSolid: "\u{f587}",
            FAIcon.FAGrinTearsRegular: "\u{f588}",
            FAIcon.FAGrinTearsSolid: "\u{f588}",
            FAIcon.FAGrinTongueRegular: "\u{f589}",
            FAIcon.FAGrinTongueSolid: "\u{f589}",
            FAIcon.FAGrinTongueSquintRegular: "\u{f58a}",
            FAIcon.FAGrinTongueSquintSolid: "\u{f58a}",
            FAIcon.FAGrinTongueWinkRegular: "\u{f58b}",
            FAIcon.FAGrinTongueWinkSolid: "\u{f58b}",
            FAIcon.FAGrinWinkRegular: "\u{f58c}",
            FAIcon.FAGrinWinkSolid: "\u{f58c}",
            FAIcon.FAGripHorizontalSolid: "\u{f58d}",
            FAIcon.FAGripLinesSolid: "\u{f7a4}",
            FAIcon.FAGripLinesVerticalSolid: "\u{f7a5}",
            FAIcon.FAGripVerticalSolid: "\u{f58e}",
            FAIcon.FAGuitarSolid: "\u{f7a6}",
            FAIcon.FAHSquareSolid: "\u{f0fd}",
            FAIcon.FAHamburgerSolid: "\u{f805}",
            FAIcon.FAHammerSolid: "\u{f6e3}",
            FAIcon.FAHamsaSolid: "\u{f665}",
            FAIcon.FAHandHoldingHeartSolid: "\u{f4be}",
            FAIcon.FAHandHoldingSolid: "\u{f4bd}",
            FAIcon.FAHandHoldingUsdSolid: "\u{f4c0}",
            FAIcon.FAHandLizardRegular: "\u{f258}",
            FAIcon.FAHandLizardSolid: "\u{f258}",
            FAIcon.FAHandMiddleFingerSolid: "\u{f806}",
            FAIcon.FAHandPaperRegular: "\u{f256}",
            FAIcon.FAHandPaperSolid: "\u{f256}",
            FAIcon.FAHandPeaceRegular: "\u{f25b}",
            FAIcon.FAHandPeaceSolid: "\u{f25b}",
            FAIcon.FAHandPointDownRegular: "\u{f0a7}",
            FAIcon.FAHandPointDownSolid: "\u{f0a7}",
            FAIcon.FAHandPointLeftRegular: "\u{f0a5}",
            FAIcon.FAHandPointLeftSolid: "\u{f0a5}",
            FAIcon.FAHandPointRightRegular: "\u{f0a4}",
            FAIcon.FAHandPointRightSolid: "\u{f0a4}",
            FAIcon.FAHandPointUpRegular: "\u{f0a6}",
            FAIcon.FAHandPointUpSolid: "\u{f0a6}",
            FAIcon.FAHandPointerRegular: "\u{f25a}",
            FAIcon.FAHandPointerSolid: "\u{f25a}",
            FAIcon.FAHandRockRegular: "\u{f255}",
            FAIcon.FAHandRockSolid: "\u{f255}",
            FAIcon.FAHandScissorsRegular: "\u{f257}",
            FAIcon.FAHandScissorsSolid: "\u{f257}",
            FAIcon.FAHandSpockRegular: "\u{f259}",
            FAIcon.FAHandSpockSolid: "\u{f259}",
            FAIcon.FAHandsHelpingSolid: "\u{f4c4}",
            FAIcon.FAHandsSolid: "\u{f4c2}",
            FAIcon.FAHandshakeRegular: "\u{f2b5}",
            FAIcon.FAHandshakeSolid: "\u{f2b5}",
            FAIcon.FAHanukiahSolid: "\u{f6e6}",
            FAIcon.FAHardHatSolid: "\u{f807}",
            FAIcon.FAHashtagSolid: "\u{f292}",
            FAIcon.FAHatCowboySideSolid: "\u{f8c1}",
            FAIcon.FAHatCowboySolid: "\u{f8c0}",
            FAIcon.FAHatWizardSolid: "\u{f6e8}",
            FAIcon.FAHaykalSolid: "\u{f666}",
            FAIcon.FAHddRegular: "\u{f0a0}",
            FAIcon.FAHddSolid: "\u{f0a0}",
            FAIcon.FAHeadingSolid: "\u{f1dc}",
            FAIcon.FAHeadphonesAltSolid: "\u{f58f}",
            FAIcon.FAHeadphonesSolid: "\u{f025}",
            FAIcon.FAHeadsetSolid: "\u{f590}",
            FAIcon.FAHeartBrokenSolid: "\u{f7a9}",
            FAIcon.FAHeartRegular: "\u{f004}",
            FAIcon.FAHeartSolid: "\u{f004}",
            FAIcon.FAHeartbeatSolid: "\u{f21e}",
            FAIcon.FAHelicopterSolid: "\u{f533}",
            FAIcon.FAHighlighterSolid: "\u{f591}",
            FAIcon.FAHikingSolid: "\u{f6ec}",
            FAIcon.FAHippoSolid: "\u{f6ed}",
            FAIcon.FAHistorySolid: "\u{f1da}",
            FAIcon.FAHockeyPuckSolid: "\u{f453}",
            FAIcon.FAHollyBerrySolid: "\u{f7aa}",
            FAIcon.FAHomeSolid: "\u{f015}",
            FAIcon.FAHorseHeadSolid: "\u{f7ab}",
            FAIcon.FAHorseSolid: "\u{f6f0}",
            FAIcon.FAHospitalAltSolid: "\u{f47d}",
            FAIcon.FAHospitalRegular: "\u{f0f8}",
            FAIcon.FAHospitalSolid: "\u{f0f8}",
            FAIcon.FAHospitalSymbolSolid: "\u{f47e}",
            FAIcon.FAHotTubSolid: "\u{f593}",
            FAIcon.FAHotdogSolid: "\u{f80f}",
            FAIcon.FAHotelSolid: "\u{f594}",
            FAIcon.FAHourglassEndSolid: "\u{f253}",
            FAIcon.FAHourglassHalfSolid: "\u{f252}",
            FAIcon.FAHourglassRegular: "\u{f254}",
            FAIcon.FAHourglassSolid: "\u{f254}",
            FAIcon.FAHourglassStartSolid: "\u{f251}",
            FAIcon.FAHouseDamageSolid: "\u{f6f1}",
            FAIcon.FAHryvniaSolid: "\u{f6f2}",
            FAIcon.FAICursorSolid: "\u{f246}",
            FAIcon.FAIceCreamSolid: "\u{f810}",
            FAIcon.FAIciclesSolid: "\u{f7ad}",
            FAIcon.FAIconsSolid: "\u{f86d}",
            FAIcon.FAIdBadgeRegular: "\u{f2c1}",
            FAIcon.FAIdBadgeSolid: "\u{f2c1}",
            FAIcon.FAIdCardAltSolid: "\u{f47f}",
            FAIcon.FAIdCardRegular: "\u{f2c2}",
            FAIcon.FAIdCardSolid: "\u{f2c2}",
            FAIcon.FAIglooSolid: "\u{f7ae}",
            FAIcon.FAImageRegular: "\u{f03e}",
            FAIcon.FAImageSolid: "\u{f03e}",
            FAIcon.FAImagesRegular: "\u{f302}",
            FAIcon.FAImagesSolid: "\u{f302}",
            FAIcon.FAInboxSolid: "\u{f01c}",
            FAIcon.FAIndentSolid: "\u{f03c}",
            FAIcon.FAIndustrySolid: "\u{f275}",
            FAIcon.FAInfinitySolid: "\u{f534}",
            FAIcon.FAInfoCircleSolid: "\u{f05a}",
            FAIcon.FAInfoSolid: "\u{f129}",
            FAIcon.FAItalicSolid: "\u{f033}",
            FAIcon.FAJediSolid: "\u{f669}",
            FAIcon.FAJointSolid: "\u{f595}",
            FAIcon.FAJournalWhillsSolid: "\u{f66a}",
            FAIcon.FAKaabaSolid: "\u{f66b}",
            FAIcon.FAKeySolid: "\u{f084}",
            FAIcon.FAKeyboardRegular: "\u{f11c}",
            FAIcon.FAKeyboardSolid: "\u{f11c}",
            FAIcon.FAKhandaSolid: "\u{f66d}",
            FAIcon.FAKissBeamRegular: "\u{f597}",
            FAIcon.FAKissBeamSolid: "\u{f597}",
            FAIcon.FAKissRegular: "\u{f596}",
            FAIcon.FAKissSolid: "\u{f596}",
            FAIcon.FAKissWinkHeartRegular: "\u{f598}",
            FAIcon.FAKissWinkHeartSolid: "\u{f598}",
            FAIcon.FAKiwiBirdSolid: "\u{f535}",
            FAIcon.FALandmarkSolid: "\u{f66f}",
            FAIcon.FALanguageSolid: "\u{f1ab}",
            FAIcon.FALaptopCodeSolid: "\u{f5fc}",
            FAIcon.FALaptopMedicalSolid: "\u{f812}",
            FAIcon.FALaptopSolid: "\u{f109}",
            FAIcon.FALaughBeamRegular: "\u{f59a}",
            FAIcon.FALaughBeamSolid: "\u{f59a}",
            FAIcon.FALaughRegular: "\u{f599}",
            FAIcon.FALaughSolid: "\u{f599}",
            FAIcon.FALaughSquintRegular: "\u{f59b}",
            FAIcon.FALaughSquintSolid: "\u{f59b}",
            FAIcon.FALaughWinkRegular: "\u{f59c}",
            FAIcon.FALaughWinkSolid: "\u{f59c}",
            FAIcon.FALayerGroupSolid: "\u{f5fd}",
            FAIcon.FALeafSolid: "\u{f06c}",
            FAIcon.FALemonRegular: "\u{f094}",
            FAIcon.FALemonSolid: "\u{f094}",
            FAIcon.FALessThanEqualSolid: "\u{f537}",
            FAIcon.FALessThanSolid: "\u{f536}",
            FAIcon.FALevelDownAltSolid: "\u{f3be}",
            FAIcon.FALevelUpAltSolid: "\u{f3bf}",
            FAIcon.FALifeRingRegular: "\u{f1cd}",
            FAIcon.FALifeRingSolid: "\u{f1cd}",
            FAIcon.FALightbulbRegular: "\u{f0eb}",
            FAIcon.FALightbulbSolid: "\u{f0eb}",
            FAIcon.FALinkSolid: "\u{f0c1}",
            FAIcon.FALiraSignSolid: "\u{f195}",
            FAIcon.FAListAltRegular: "\u{f022}",
            FAIcon.FAListAltSolid: "\u{f022}",
            FAIcon.FAListOlSolid: "\u{f0cb}",
            FAIcon.FAListSolid: "\u{f03a}",
            FAIcon.FAListUlSolid: "\u{f0ca}",
            FAIcon.FALocationArrowSolid: "\u{f124}",
            FAIcon.FALockOpenSolid: "\u{f3c1}",
            FAIcon.FALockSolid: "\u{f023}",
            FAIcon.FALongArrowAltDownSolid: "\u{f309}",
            FAIcon.FALongArrowAltLeftSolid: "\u{f30a}",
            FAIcon.FALongArrowAltRightSolid: "\u{f30b}",
            FAIcon.FALongArrowAltUpSolid: "\u{f30c}",
            FAIcon.FALowVisionSolid: "\u{f2a8}",
            FAIcon.FALuggageCartSolid: "\u{f59d}",
            FAIcon.FAMagicSolid: "\u{f0d0}",
            FAIcon.FAMagnetSolid: "\u{f076}",
            FAIcon.FAMailBulkSolid: "\u{f674}",
            FAIcon.FAMaleSolid: "\u{f183}",
            FAIcon.FAMapMarkedAltSolid: "\u{f5a0}",
            FAIcon.FAMapMarkedSolid: "\u{f59f}",
            FAIcon.FAMapMarkerAltSolid: "\u{f3c5}",
            FAIcon.FAMapMarkerSolid: "\u{f041}",
            FAIcon.FAMapPinSolid: "\u{f276}",
            FAIcon.FAMapRegular: "\u{f279}",
            FAIcon.FAMapSignsSolid: "\u{f277}",
            FAIcon.FAMapSolid: "\u{f279}",
            FAIcon.FAMarkerSolid: "\u{f5a1}",
            FAIcon.FAMarsDoubleSolid: "\u{f227}",
            FAIcon.FAMarsSolid: "\u{f222}",
            FAIcon.FAMarsStrokeHSolid: "\u{f22b}",
            FAIcon.FAMarsStrokeSolid: "\u{f229}",
            FAIcon.FAMarsStrokeVSolid: "\u{f22a}",
            FAIcon.FAMaskSolid: "\u{f6fa}",
            FAIcon.FAMedalSolid: "\u{f5a2}",
            FAIcon.FAMedkitSolid: "\u{f0fa}",
            FAIcon.FAMehBlankRegular: "\u{f5a4}",
            FAIcon.FAMehBlankSolid: "\u{f5a4}",
            FAIcon.FAMehRegular: "\u{f11a}",
            FAIcon.FAMehRollingEyesRegular: "\u{f5a5}",
            FAIcon.FAMehRollingEyesSolid: "\u{f5a5}",
            FAIcon.FAMehSolid: "\u{f11a}",
            FAIcon.FAMemorySolid: "\u{f538}",
            FAIcon.FAMenorahSolid: "\u{f676}",
            FAIcon.FAMercurySolid: "\u{f223}",
            FAIcon.FAMeteorSolid: "\u{f753}",
            FAIcon.FAMicrochipSolid: "\u{f2db}",
            FAIcon.FAMicrophoneAltSlashSolid: "\u{f539}",
            FAIcon.FAMicrophoneAltSolid: "\u{f3c9}",
            FAIcon.FAMicrophoneSlashSolid: "\u{f131}",
            FAIcon.FAMicrophoneSolid: "\u{f130}",
            FAIcon.FAMicroscopeSolid: "\u{f610}",
            FAIcon.FAMinusCircleSolid: "\u{f056}",
            FAIcon.FAMinusSolid: "\u{f068}",
            FAIcon.FAMinusSquareRegular: "\u{f146}",
            FAIcon.FAMinusSquareSolid: "\u{f146}",
            FAIcon.FAMittenSolid: "\u{f7b5}",
            FAIcon.FAMobileAltSolid: "\u{f3cd}",
            FAIcon.FAMobileSolid: "\u{f10b}",
            FAIcon.FAMoneyBillAltRegular: "\u{f3d1}",
            FAIcon.FAMoneyBillAltSolid: "\u{f3d1}",
            FAIcon.FAMoneyBillSolid: "\u{f0d6}",
            FAIcon.FAMoneyBillWaveAltSolid: "\u{f53b}",
            FAIcon.FAMoneyBillWaveSolid: "\u{f53a}",
            FAIcon.FAMoneyCheckAltSolid: "\u{f53d}",
            FAIcon.FAMoneyCheckSolid: "\u{f53c}",
            FAIcon.FAMonumentSolid: "\u{f5a6}",
            FAIcon.FAMoonRegular: "\u{f186}",
            FAIcon.FAMoonSolid: "\u{f186}",
            FAIcon.FAMortarPestleSolid: "\u{f5a7}",
            FAIcon.FAMosqueSolid: "\u{f678}",
            FAIcon.FAMotorcycleSolid: "\u{f21c}",
            FAIcon.FAMountainSolid: "\u{f6fc}",
            FAIcon.FAMousePointerSolid: "\u{f245}",
            FAIcon.FAMouseSolid: "\u{f8cc}",
            FAIcon.FAMugHotSolid: "\u{f7b6}",
            FAIcon.FAMusicSolid: "\u{f001}",
            FAIcon.FANetworkWiredSolid: "\u{f6ff}",
            FAIcon.FANeuterSolid: "\u{f22c}",
            FAIcon.FANewspaperRegular: "\u{f1ea}",
            FAIcon.FANewspaperSolid: "\u{f1ea}",
            FAIcon.FANotEqualSolid: "\u{f53e}",
            FAIcon.FANotesMedicalSolid: "\u{f481}",
            FAIcon.FAObjectGroupRegular: "\u{f247}",
            FAIcon.FAObjectGroupSolid: "\u{f247}",
            FAIcon.FAObjectUngroupRegular: "\u{f248}",
            FAIcon.FAObjectUngroupSolid: "\u{f248}",
            FAIcon.FAOilCanSolid: "\u{f613}",
            FAIcon.FAOmSolid: "\u{f679}",
            FAIcon.FAOtterSolid: "\u{f700}",
            FAIcon.FAOutdentSolid: "\u{f03b}",
            FAIcon.FAPagerSolid: "\u{f815}",
            FAIcon.FAPaintBrushSolid: "\u{f1fc}",
            FAIcon.FAPaintRollerSolid: "\u{f5aa}",
            FAIcon.FAPaletteSolid: "\u{f53f}",
            FAIcon.FAPalletSolid: "\u{f482}",
            FAIcon.FAPaperPlaneRegular: "\u{f1d8}",
            FAIcon.FAPaperPlaneSolid: "\u{f1d8}",
            FAIcon.FAPaperclipSolid: "\u{f0c6}",
            FAIcon.FAParachuteBoxSolid: "\u{f4cd}",
            FAIcon.FAParagraphSolid: "\u{f1dd}",
            FAIcon.FAParkingSolid: "\u{f540}",
            FAIcon.FAPassportSolid: "\u{f5ab}",
            FAIcon.FAPastafarianismSolid: "\u{f67b}",
            FAIcon.FAPasteSolid: "\u{f0ea}",
            FAIcon.FAPauseCircleRegular: "\u{f28b}",
            FAIcon.FAPauseCircleSolid: "\u{f28b}",
            FAIcon.FAPauseSolid: "\u{f04c}",
            FAIcon.FAPawSolid: "\u{f1b0}",
            FAIcon.FAPeaceSolid: "\u{f67c}",
            FAIcon.FAPenAltSolid: "\u{f305}",
            FAIcon.FAPenFancySolid: "\u{f5ac}",
            FAIcon.FAPenNibSolid: "\u{f5ad}",
            FAIcon.FAPenSolid: "\u{f304}",
            FAIcon.FAPenSquareSolid: "\u{f14b}",
            FAIcon.FAPencilAltSolid: "\u{f303}",
            FAIcon.FAPencilRulerSolid: "\u{f5ae}",
            FAIcon.FAPeopleCarrySolid: "\u{f4ce}",
            FAIcon.FAPepperHotSolid: "\u{f816}",
            FAIcon.FAPercentSolid: "\u{f295}",
            FAIcon.FAPercentageSolid: "\u{f541}",
            FAIcon.FAPersonBoothSolid: "\u{f756}",
            FAIcon.FAPhoneAltSolid: "\u{f879}",
            FAIcon.FAPhoneSlashSolid: "\u{f3dd}",
            FAIcon.FAPhoneSolid: "\u{f095}",
            FAIcon.FAPhoneSquareAltSolid: "\u{f87b}",
            FAIcon.FAPhoneSquareSolid: "\u{f098}",
            FAIcon.FAPhoneVolumeSolid: "\u{f2a0}",
            FAIcon.FAPhotoVideoSolid: "\u{f87c}",
            FAIcon.FAPiggyBankSolid: "\u{f4d3}",
            FAIcon.FAPillsSolid: "\u{f484}",
            FAIcon.FAPizzaSliceSolid: "\u{f818}",
            FAIcon.FAPlaceOfWorshipSolid: "\u{f67f}",
            FAIcon.FAPlaneArrivalSolid: "\u{f5af}",
            FAIcon.FAPlaneDepartureSolid: "\u{f5b0}",
            FAIcon.FAPlaneSolid: "\u{f072}",
            FAIcon.FAPlayCircleRegular: "\u{f144}",
            FAIcon.FAPlayCircleSolid: "\u{f144}",
            FAIcon.FAPlaySolid: "\u{f04b}",
            FAIcon.FAPlugSolid: "\u{f1e6}",
            FAIcon.FAPlusCircleSolid: "\u{f055}",
            FAIcon.FAPlusSolid: "\u{f067}",
            FAIcon.FAPlusSquareRegular: "\u{f0fe}",
            FAIcon.FAPlusSquareSolid: "\u{f0fe}",
            FAIcon.FAPodcastSolid: "\u{f2ce}",
            FAIcon.FAPollHSolid: "\u{f682}",
            FAIcon.FAPollSolid: "\u{f681}",
            FAIcon.FAPooSolid: "\u{f2fe}",
            FAIcon.FAPooStormSolid: "\u{f75a}",
            FAIcon.FAPoopSolid: "\u{f619}",
            FAIcon.FAPortraitSolid: "\u{f3e0}",
            FAIcon.FAPoundSignSolid: "\u{f154}",
            FAIcon.FAPowerOffSolid: "\u{f011}",
            FAIcon.FAPraySolid: "\u{f683}",
            FAIcon.FAPrayingHandsSolid: "\u{f684}",
            FAIcon.FAPrescriptionBottleAltSolid: "\u{f486}",
            FAIcon.FAPrescriptionBottleSolid: "\u{f485}",
            FAIcon.FAPrescriptionSolid: "\u{f5b1}",
            FAIcon.FAPrintSolid: "\u{f02f}",
            FAIcon.FAProceduresSolid: "\u{f487}",
            FAIcon.FAProjectDiagramSolid: "\u{f542}",
            FAIcon.FAPuzzlePieceSolid: "\u{f12e}",
            FAIcon.FAQrcodeSolid: "\u{f029}",
            FAIcon.FAQuestionCircleRegular: "\u{f059}",
            FAIcon.FAQuestionCircleSolid: "\u{f059}",
            FAIcon.FAQuestionSolid: "\u{f128}",
            FAIcon.FAQuidditchSolid: "\u{f458}",
            FAIcon.FAQuoteLeftSolid: "\u{f10d}",
            FAIcon.FAQuoteRightSolid: "\u{f10e}",
            FAIcon.FAQuranSolid: "\u{f687}",
            FAIcon.FARadiationAltSolid: "\u{f7ba}",
            FAIcon.FARadiationSolid: "\u{f7b9}",
            FAIcon.FARainbowSolid: "\u{f75b}",
            FAIcon.FARandomSolid: "\u{f074}",
            FAIcon.FAReceiptSolid: "\u{f543}",
            FAIcon.FARecordVinylSolid: "\u{f8d9}",
            FAIcon.FARecycleSolid: "\u{f1b8}",
            FAIcon.FARedoAltSolid: "\u{f2f9}",
            FAIcon.FARedoSolid: "\u{f01e}",
            FAIcon.FARegisteredRegular: "\u{f25d}",
            FAIcon.FARegisteredSolid: "\u{f25d}",
            FAIcon.FARemoveFormatSolid: "\u{f87d}",
            FAIcon.FAReplyAllSolid: "\u{f122}",
            FAIcon.FAReplySolid: "\u{f3e5}",
            FAIcon.FARepublicanSolid: "\u{f75e}",
            FAIcon.FARestroomSolid: "\u{f7bd}",
            FAIcon.FARetweetSolid: "\u{f079}",
            FAIcon.FARibbonSolid: "\u{f4d6}",
            FAIcon.FARingSolid: "\u{f70b}",
            FAIcon.FARoadSolid: "\u{f018}",
            FAIcon.FARobotSolid: "\u{f544}",
            FAIcon.FARocketSolid: "\u{f135}",
            FAIcon.FARouteSolid: "\u{f4d7}",
            FAIcon.FARssSolid: "\u{f09e}",
            FAIcon.FARssSquareSolid: "\u{f143}",
            FAIcon.FARubleSignSolid: "\u{f158}",
            FAIcon.FARulerCombinedSolid: "\u{f546}",
            FAIcon.FARulerHorizontalSolid: "\u{f547}",
            FAIcon.FARulerSolid: "\u{f545}",
            FAIcon.FARulerVerticalSolid: "\u{f548}",
            FAIcon.FARunningSolid: "\u{f70c}",
            FAIcon.FARupeeSignSolid: "\u{f156}",
            FAIcon.FASadCryRegular: "\u{f5b3}",
            FAIcon.FASadCrySolid: "\u{f5b3}",
            FAIcon.FASadTearRegular: "\u{f5b4}",
            FAIcon.FASadTearSolid: "\u{f5b4}",
            FAIcon.FASatelliteDishSolid: "\u{f7c0}",
            FAIcon.FASatelliteSolid: "\u{f7bf}",
            FAIcon.FASaveRegular: "\u{f0c7}",
            FAIcon.FASaveSolid: "\u{f0c7}",
            FAIcon.FASchoolSolid: "\u{f549}",
            FAIcon.FAScrewdriverSolid: "\u{f54a}",
            FAIcon.FAScrollSolid: "\u{f70e}",
            FAIcon.FASdCardSolid: "\u{f7c2}",
            FAIcon.FASearchDollarSolid: "\u{f688}",
            FAIcon.FASearchLocationSolid: "\u{f689}",
            FAIcon.FASearchMinusSolid: "\u{f010}",
            FAIcon.FASearchPlusSolid: "\u{f00e}",
            FAIcon.FASearchSolid: "\u{f002}",
            FAIcon.FASeedlingSolid: "\u{f4d8}",
            FAIcon.FAServerSolid: "\u{f233}",
            FAIcon.FAShapesSolid: "\u{f61f}",
            FAIcon.FAShareAltSolid: "\u{f1e0}",
            FAIcon.FAShareAltSquareSolid: "\u{f1e1}",
            FAIcon.FAShareSolid: "\u{f064}",
            FAIcon.FAShareSquareRegular: "\u{f14d}",
            FAIcon.FAShareSquareSolid: "\u{f14d}",
            FAIcon.FAShekelSignSolid: "\u{f20b}",
            FAIcon.FAShieldAltSolid: "\u{f3ed}",
            FAIcon.FAShipSolid: "\u{f21a}",
            FAIcon.FAShippingFastSolid: "\u{f48b}",
            FAIcon.FAShoePrintsSolid: "\u{f54b}",
            FAIcon.FAShoppingBagSolid: "\u{f290}",
            FAIcon.FAShoppingBasketSolid: "\u{f291}",
            FAIcon.FAShoppingCartSolid: "\u{f07a}",
            FAIcon.FAShowerSolid: "\u{f2cc}",
            FAIcon.FAShuttleVanSolid: "\u{f5b6}",
            FAIcon.FASignInAltSolid: "\u{f2f6}",
            FAIcon.FASignLanguageSolid: "\u{f2a7}",
            FAIcon.FASignOutAltSolid: "\u{f2f5}",
            FAIcon.FASignSolid: "\u{f4d9}",
            FAIcon.FASignalSolid: "\u{f012}",
            FAIcon.FASignatureSolid: "\u{f5b7}",
            FAIcon.FASimCardSolid: "\u{f7c4}",
            FAIcon.FASitemapSolid: "\u{f0e8}",
            FAIcon.FASkatingSolid: "\u{f7c5}",
            FAIcon.FASkiingNordicSolid: "\u{f7ca}",
            FAIcon.FASkiingSolid: "\u{f7c9}",
            FAIcon.FASkullCrossbonesSolid: "\u{f714}",
            FAIcon.FASkullSolid: "\u{f54c}",
            FAIcon.FASlashSolid: "\u{f715}",
            FAIcon.FASleighSolid: "\u{f7cc}",
            FAIcon.FASlidersHSolid: "\u{f1de}",
            FAIcon.FASmileBeamRegular: "\u{f5b8}",
            FAIcon.FASmileBeamSolid: "\u{f5b8}",
            FAIcon.FASmileRegular: "\u{f118}",
            FAIcon.FASmileSolid: "\u{f118}",
            FAIcon.FASmileWinkRegular: "\u{f4da}",
            FAIcon.FASmileWinkSolid: "\u{f4da}",
            FAIcon.FASmogSolid: "\u{f75f}",
            FAIcon.FASmokingBanSolid: "\u{f54d}",
            FAIcon.FASmokingSolid: "\u{f48d}",
            FAIcon.FASmsSolid: "\u{f7cd}",
            FAIcon.FASnowboardingSolid: "\u{f7ce}",
            FAIcon.FASnowflakeRegular: "\u{f2dc}",
            FAIcon.FASnowflakeSolid: "\u{f2dc}",
            FAIcon.FASnowmanSolid: "\u{f7d0}",
            FAIcon.FASnowplowSolid: "\u{f7d2}",
            FAIcon.FASocksSolid: "\u{f696}",
            FAIcon.FASolarPanelSolid: "\u{f5ba}",
            FAIcon.FASortAlphaDownAltSolid: "\u{f881}",
            FAIcon.FASortAlphaDownSolid: "\u{f15d}",
            FAIcon.FASortAlphaUpAltSolid: "\u{f882}",
            FAIcon.FASortAlphaUpSolid: "\u{f15e}",
            FAIcon.FASortAmountDownAltSolid: "\u{f884}",
            FAIcon.FASortAmountDownSolid: "\u{f160}",
            FAIcon.FASortAmountUpAltSolid: "\u{f885}",
            FAIcon.FASortAmountUpSolid: "\u{f161}",
            FAIcon.FASortDownSolid: "\u{f0dd}",
            FAIcon.FASortNumericDownAltSolid: "\u{f886}",
            FAIcon.FASortNumericDownSolid: "\u{f162}",
            FAIcon.FASortNumericUpAltSolid: "\u{f887}",
            FAIcon.FASortNumericUpSolid: "\u{f163}",
            FAIcon.FASortSolid: "\u{f0dc}",
            FAIcon.FASortUpSolid: "\u{f0de}",
            FAIcon.FASpaSolid: "\u{f5bb}",
            FAIcon.FASpaceShuttleSolid: "\u{f197}",
            FAIcon.FASpellCheckSolid: "\u{f891}",
            FAIcon.FASpiderSolid: "\u{f717}",
            FAIcon.FASpinnerSolid: "\u{f110}",
            FAIcon.FASplotchSolid: "\u{f5bc}",
            FAIcon.FASprayCanSolid: "\u{f5bd}",
            FAIcon.FASquareFullSolid: "\u{f45c}",
            FAIcon.FASquareRegular: "\u{f0c8}",
            FAIcon.FASquareRootAltSolid: "\u{f698}",
            FAIcon.FASquareSolid: "\u{f0c8}",
            FAIcon.FAStampSolid: "\u{f5bf}",
            FAIcon.FAStarAndCrescentSolid: "\u{f699}",
            FAIcon.FAStarHalfAltSolid: "\u{f5c0}",
            FAIcon.FAStarHalfRegular: "\u{f089}",
            FAIcon.FAStarHalfSolid: "\u{f089}",
            FAIcon.FAStarOfDavidSolid: "\u{f69a}",
            FAIcon.FAStarOfLifeSolid: "\u{f621}",
            FAIcon.FAStarRegular: "\u{f005}",
            FAIcon.FAStarSolid: "\u{f005}",
            FAIcon.FAStepBackwardSolid: "\u{f048}",
            FAIcon.FAStepForwardSolid: "\u{f051}",
            FAIcon.FAStethoscopeSolid: "\u{f0f1}",
            FAIcon.FAStickyNoteRegular: "\u{f249}",
            FAIcon.FAStickyNoteSolid: "\u{f249}",
            FAIcon.FAStopCircleRegular: "\u{f28d}",
            FAIcon.FAStopCircleSolid: "\u{f28d}",
            FAIcon.FAStopSolid: "\u{f04d}",
            FAIcon.FAStopwatchSolid: "\u{f2f2}",
            FAIcon.FAStoreAltSolid: "\u{f54f}",
            FAIcon.FAStoreSolid: "\u{f54e}",
            FAIcon.FAStreamSolid: "\u{f550}",
            FAIcon.FAStreetViewSolid: "\u{f21d}",
            FAIcon.FAStrikethroughSolid: "\u{f0cc}",
            FAIcon.FAStroopwafelSolid: "\u{f551}",
            FAIcon.FASubscriptSolid: "\u{f12c}",
            FAIcon.FASubwaySolid: "\u{f239}",
            FAIcon.FASuitcaseRollingSolid: "\u{f5c1}",
            FAIcon.FASuitcaseSolid: "\u{f0f2}",
            FAIcon.FASunRegular: "\u{f185}",
            FAIcon.FASunSolid: "\u{f185}",
            FAIcon.FASuperscriptSolid: "\u{f12b}",
            FAIcon.FASurpriseRegular: "\u{f5c2}",
            FAIcon.FASurpriseSolid: "\u{f5c2}",
            FAIcon.FASwatchbookSolid: "\u{f5c3}",
            FAIcon.FASwimmerSolid: "\u{f5c4}",
            FAIcon.FASwimmingPoolSolid: "\u{f5c5}",
            FAIcon.FASynagogueSolid: "\u{f69b}",
            FAIcon.FASyncAltSolid: "\u{f2f1}",
            FAIcon.FASyncSolid: "\u{f021}",
            FAIcon.FASyringeSolid: "\u{f48e}",
            FAIcon.FATableSolid: "\u{f0ce}",
            FAIcon.FATableTennisSolid: "\u{f45d}",
            FAIcon.FATabletAltSolid: "\u{f3fa}",
            FAIcon.FATabletSolid: "\u{f10a}",
            FAIcon.FATabletsSolid: "\u{f490}",
            FAIcon.FATachometerAltSolid: "\u{f3fd}",
            FAIcon.FATagSolid: "\u{f02b}",
            FAIcon.FATagsSolid: "\u{f02c}",
            FAIcon.FATapeSolid: "\u{f4db}",
            FAIcon.FATasksSolid: "\u{f0ae}",
            FAIcon.FATaxiSolid: "\u{f1ba}",
            FAIcon.FATeethOpenSolid: "\u{f62f}",
            FAIcon.FATeethSolid: "\u{f62e}",
            FAIcon.FATemperatureHighSolid: "\u{f769}",
            FAIcon.FATemperatureLowSolid: "\u{f76b}",
            FAIcon.FATengeSolid: "\u{f7d7}",
            FAIcon.FATerminalSolid: "\u{f120}",
            FAIcon.FATextHeightSolid: "\u{f034}",
            FAIcon.FATextWidthSolid: "\u{f035}",
            FAIcon.FAThLargeSolid: "\u{f009}",
            FAIcon.FAThListSolid: "\u{f00b}",
            FAIcon.FAThSolid: "\u{f00a}",
            FAIcon.FATheaterMasksSolid: "\u{f630}",
            FAIcon.FAThermometerEmptySolid: "\u{f2cb}",
            FAIcon.FAThermometerFullSolid: "\u{f2c7}",
            FAIcon.FAThermometerHalfSolid: "\u{f2c9}",
            FAIcon.FAThermometerQuarterSolid: "\u{f2ca}",
            FAIcon.FAThermometerSolid: "\u{f491}",
            FAIcon.FAThermometerThreeQuartersSolid: "\u{f2c8}",
            FAIcon.FAThumbsDownRegular: "\u{f165}",
            FAIcon.FAThumbsDownSolid: "\u{f165}",
            FAIcon.FAThumbsUpRegular: "\u{f164}",
            FAIcon.FAThumbsUpSolid: "\u{f164}",
            FAIcon.FAThumbtackSolid: "\u{f08d}",
            FAIcon.FATicketAltSolid: "\u{f3ff}",
            FAIcon.FATimesCircleRegular: "\u{f057}",
            FAIcon.FATimesCircleSolid: "\u{f057}",
            FAIcon.FATimesSolid: "\u{f00d}",
            FAIcon.FATintSlashSolid: "\u{f5c7}",
            FAIcon.FATintSolid: "\u{f043}",
            FAIcon.FATiredRegular: "\u{f5c8}",
            FAIcon.FATiredSolid: "\u{f5c8}",
            FAIcon.FAToggleOffSolid: "\u{f204}",
            FAIcon.FAToggleOnSolid: "\u{f205}",
            FAIcon.FAToiletPaperSolid: "\u{f71e}",
            FAIcon.FAToiletSolid: "\u{f7d8}",
            FAIcon.FAToolboxSolid: "\u{f552}",
            FAIcon.FAToolsSolid: "\u{f7d9}",
            FAIcon.FAToothSolid: "\u{f5c9}",
            FAIcon.FATorahSolid: "\u{f6a0}",
            FAIcon.FAToriiGateSolid: "\u{f6a1}",
            FAIcon.FATractorSolid: "\u{f722}",
            FAIcon.FATrademarkSolid: "\u{f25c}",
            FAIcon.FATrafficLightSolid: "\u{f637}",
            FAIcon.FATrainSolid: "\u{f238}",
            FAIcon.FATramSolid: "\u{f7da}",
            FAIcon.FATransgenderAltSolid: "\u{f225}",
            FAIcon.FATransgenderSolid: "\u{f224}",
            FAIcon.FATrashAltRegular: "\u{f2ed}",
            FAIcon.FATrashAltSolid: "\u{f2ed}",
            FAIcon.FATrashRestoreAltSolid: "\u{f82a}",
            FAIcon.FATrashRestoreSolid: "\u{f829}",
            FAIcon.FATrashSolid: "\u{f1f8}",
            FAIcon.FATreeSolid: "\u{f1bb}",
            FAIcon.FATrophySolid: "\u{f091}",
            FAIcon.FATruckLoadingSolid: "\u{f4de}",
            FAIcon.FATruckMonsterSolid: "\u{f63b}",
            FAIcon.FATruckMovingSolid: "\u{f4df}",
            FAIcon.FATruckPickupSolid: "\u{f63c}",
            FAIcon.FATruckSolid: "\u{f0d1}",
            FAIcon.FATshirtSolid: "\u{f553}",
            FAIcon.FATtySolid: "\u{f1e4}",
            FAIcon.FATvSolid: "\u{f26c}",
            FAIcon.FAUmbrellaBeachSolid: "\u{f5ca}",
            FAIcon.FAUmbrellaSolid: "\u{f0e9}",
            FAIcon.FAUnderlineSolid: "\u{f0cd}",
            FAIcon.FAUndoAltSolid: "\u{f2ea}",
            FAIcon.FAUndoSolid: "\u{f0e2}",
            FAIcon.FAUniversalAccessSolid: "\u{f29a}",
            FAIcon.FAUniversitySolid: "\u{f19c}",
            FAIcon.FAUnlinkSolid: "\u{f127}",
            FAIcon.FAUnlockAltSolid: "\u{f13e}",
            FAIcon.FAUnlockSolid: "\u{f09c}",
            FAIcon.FAUploadSolid: "\u{f093}",
            FAIcon.FAUserAltSlashSolid: "\u{f4fa}",
            FAIcon.FAUserAltSolid: "\u{f406}",
            FAIcon.FAUserAstronautSolid: "\u{f4fb}",
            FAIcon.FAUserCheckSolid: "\u{f4fc}",
            FAIcon.FAUserCircleRegular: "\u{f2bd}",
            FAIcon.FAUserCircleSolid: "\u{f2bd}",
            FAIcon.FAUserClockSolid: "\u{f4fd}",
            FAIcon.FAUserCogSolid: "\u{f4fe}",
            FAIcon.FAUserEditSolid: "\u{f4ff}",
            FAIcon.FAUserFriendsSolid: "\u{f500}",
            FAIcon.FAUserGraduateSolid: "\u{f501}",
            FAIcon.FAUserInjuredSolid: "\u{f728}",
            FAIcon.FAUserLockSolid: "\u{f502}",
            FAIcon.FAUserMdSolid: "\u{f0f0}",
            FAIcon.FAUserMinusSolid: "\u{f503}",
            FAIcon.FAUserNinjaSolid: "\u{f504}",
            FAIcon.FAUserNurseSolid: "\u{f82f}",
            FAIcon.FAUserPlusSolid: "\u{f234}",
            FAIcon.FAUserRegular: "\u{f007}",
            FAIcon.FAUserSecretSolid: "\u{f21b}",
            FAIcon.FAUserShieldSolid: "\u{f505}",
            FAIcon.FAUserSlashSolid: "\u{f506}",
            FAIcon.FAUserSolid: "\u{f007}",
            FAIcon.FAUserTagSolid: "\u{f507}",
            FAIcon.FAUserTieSolid: "\u{f508}",
            FAIcon.FAUserTimesSolid: "\u{f235}",
            FAIcon.FAUsersCogSolid: "\u{f509}",
            FAIcon.FAUsersSolid: "\u{f0c0}",
            FAIcon.FAUtensilSpoonSolid: "\u{f2e5}",
            FAIcon.FAUtensilsSolid: "\u{f2e7}",
            FAIcon.FAVectorSquareSolid: "\u{f5cb}",
            FAIcon.FAVenusDoubleSolid: "\u{f226}",
            FAIcon.FAVenusMarsSolid: "\u{f228}",
            FAIcon.FAVenusSolid: "\u{f221}",
            FAIcon.FAVialSolid: "\u{f492}",
            FAIcon.FAVialsSolid: "\u{f493}",
            FAIcon.FAVideoSlashSolid: "\u{f4e2}",
            FAIcon.FAVideoSolid: "\u{f03d}",
            FAIcon.FAViharaSolid: "\u{f6a7}",
            FAIcon.FAVoicemailSolid: "\u{f897}",
            FAIcon.FAVolleyballBallSolid: "\u{f45f}",
            FAIcon.FAVolumeDownSolid: "\u{f027}",
            FAIcon.FAVolumeMuteSolid: "\u{f6a9}",
            FAIcon.FAVolumeOffSolid: "\u{f026}",
            FAIcon.FAVolumeUpSolid: "\u{f028}",
            FAIcon.FAVoteYeaSolid: "\u{f772}",
            FAIcon.FAVrCardboardSolid: "\u{f729}",
            FAIcon.FAWalkingSolid: "\u{f554}",
            FAIcon.FAWalletSolid: "\u{f555}",
            FAIcon.FAWarehouseSolid: "\u{f494}",
            FAIcon.FAWaterSolid: "\u{f773}",
            FAIcon.FAWaveSquareSolid: "\u{f83e}",
            FAIcon.FAWeightHangingSolid: "\u{f5cd}",
            FAIcon.FAWeightSolid: "\u{f496}",
            FAIcon.FAWheelchairSolid: "\u{f193}",
            FAIcon.FAWifiSolid: "\u{f1eb}",
            FAIcon.FAWindSolid: "\u{f72e}",
            FAIcon.FAWindowCloseRegular: "\u{f410}",
            FAIcon.FAWindowCloseSolid: "\u{f410}",
            FAIcon.FAWindowMaximizeRegular: "\u{f2d0}",
            FAIcon.FAWindowMaximizeSolid: "\u{f2d0}",
            FAIcon.FAWindowMinimizeRegular: "\u{f2d1}",
            FAIcon.FAWindowMinimizeSolid: "\u{f2d1}",
            FAIcon.FAWindowRestoreRegular: "\u{f2d2}",
            FAIcon.FAWindowRestoreSolid: "\u{f2d2}",
            FAIcon.FAWineBottleSolid: "\u{f72f}",
            FAIcon.FAWineGlassAltSolid: "\u{f5ce}",
            FAIcon.FAWineGlassSolid: "\u{f4e3}",
            FAIcon.FAWonSignSolid: "\u{f159}",
            FAIcon.FAWrenchSolid: "\u{f0ad}",
            FAIcon.FAXRaySolid: "\u{f497}",
            FAIcon.FAYenSignSolid: "\u{f157}",
            FAIcon.FAYinYangSolid: "\u{f6ad}",
        ]
        guard let code = icons[self] else {
            return ""
        }
        return code
    }

    func font(size: CGFloat) -> UIFont {
        var font: UIFont?
        if self.rawValue >= 100000 && self.rawValue <= 199999 {
            font = UIFont(name: "FontAwesome5Brands-Regular", size: size)
        } else if self.rawValue >= 200000 && self.rawValue <= 299999 {
            font = UIFont(name: "FontAwesome5Free-Light", size: size)
        } else if self.rawValue >= 400000 && self.rawValue <= 499999 {
            font = UIFont(name: "FontAwesome5Free-Solid", size: size)
        } else {
            font = UIFont(name: "FontAwesome5Free-Regular", size: size)
        }

        if let f = font {
            return f
        }

        LogError("FontAwesome font not located - failing to LastResort font")
        for family in UIFont.familyNames {
            LogError("Family name " + family)
            let fontNames = UIFont.fontNames(forFamilyName: family)
            for font in fontNames {
                LogError(" - Font name: " + font)
            }
        }

        return UIFont.systemFont(ofSize: size) // Last resort
    }
}
