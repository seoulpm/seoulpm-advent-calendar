FormNa게 Form을 생성하자~
======================

-부제 : 가변데이터에 대해 문서 자동으로 생성하기

저자소개
-------

Silex에서 여자를 맡고있다
이번 어드벤트캘린더에서도 여자를 맡게 되었다.
perl에 입문한 첫 해에 어드벤트캘린더를 쓰지만
정작 본인 글이 올라오는 날에는 라섹으로 인해 글을 보지못한다.
(키디님의 심의가 절실할 때)


시작하며
-------

어떤 특정한 문서 틀이 필요할 때가 있습니다.
그럴 때 우리는 '서식파일', '보고서 양식' 이라고 검색하곤 합니다.
그리고 적당한 틀이 있는 doc 포맷으로 된 파일을 다운받아 내용을 채워 넣습니다.
양식을 다운 받는 이유는,
형식이 필요한 문서이면서, 데이터만 바꿔서 문서를 자주 만들어야 할 때 일것입니다.
그 예로는 마트에서 주는 영수증부터, 회사의 거래내역서, 이력서 등등 다양합니다.
이러한 보고서 서식(form)을 제공하는 사이트로 비즈폼(http://www.bizforms.co.kr/),
예스폼(ww.yesform.com/)들도 있습니다.
하지만, perl과 ODF를 사용한다면, 이러한 Form들을 FormNa게 우리손으로 만들어 볼 수도 있습니다.


준비물
-----

- OpenDocument::Template
- Catalyst


오픈도큐먼트와 함께라면
-----------

저는 ODT를 이용하여, 문서를 찍어낼 것입니다.
그러면 작업에 들어가기에 앞서
우리가 앞으로 이용하게 될 ODF,ODT에 대해서 알아봅시다.

### ODF : OpenDocumentFormat

오픈 도큐먼트 포맷(ODF)은 초기 ' 오픈오피스'에서 XML파일 포맷을 기반으로 구현한 것을
OASIS(Organization for the Advancement of Structured Information Standards) 컨소시엄이
표준화 한 파일 포맷입니다.
이 포맷은 오픈 XML기반 문서 파일 포맷으로, 기준에 따라 재사용 가능하고
텍스트 문서(odt), 스프레드 시트(ods), 차트 및 그래픽 요소(odg)등에 이용됩니다.

ODF포맷을 사용한 응용 프로그램, 오피스 군으로는 다음과 같은 것들이 있습니다.

- 자유 소프트웨어
- 리버오피스
- 오픈오피스
- 애비워드
- KOffice
- 구글 오피스(Google Docs)
- 마이크로소프트 오피스 2010/Office 2007 SP2

### ODT : OpenDocumentText

즉, ODT란 오픈도큐먼트 포맷(ODF)이 사용된 워드프로세서 텍스트 문서 입니다.
그럼 ODT는 어떻게 구성되어있을까요.
오픈도큐먼트포맷(ODF)는 일반적으로 여러개의 XML 문서와 이진 파일을 하나의 zip 컨테이너 안에 묶는 형태입니다.
ODT를 포함하여 일반적인 오픈도큐먼트포맷(ODF)의 파일 구성을 살펴 봅시다.
오픈오피스(또는 리버오피스 등  ODF를 사용하는 오피스군)를 열어,
아무 글이나 작성한후 `sample.odt` 파일로 저장한 후
`unzip` 유틸리티를 써서 어떤 구성으로 되어있는지 열어보았습니다.

    #!bash
    $ unzip sample.odt
    Archive:  sample.odt
     extracting: mimetype            
      inflating: content.xml         
      inflating: manifest.rdf        
      inflating: styles.xml          
     extracting: meta.xml            
      inflating: Thumbnails/thumbnail.png
      inflating: Configurations2/accelerator/current.xml
       creating: Configurations2/progressbar/
       creating: Configurations2/floater/
       creating: Configurations2/popupmenu/
       creating: Configurations2/menubar/
       creating: Configurations2/toolbar/
       creating: Configurations2/images/Bitmaps/
       creating: Configurations2/statusbar/
      inflating: settings.xml        
      inflating: META-INF/manifest.xml

 여기서 핵심은 `content.xml`, `meta.xml`, `styles.xml` 파일들이며 각각 하는 일은
다음과 같습니다.

- content.xml : 문서를 통해 실어나를 주 내용을 담고 있습니다. 일반적으로 텍스트, 표, 프레젠테이션 구조들입니다.
- meta.xml : 문서의 MIME 타입을 기술합니다. 생성 시간, 최종 수정 시간, 문서 수정 시 걸린 전체 시간, 낱말/쪽/표/그림 개수 같은 문서 메타데이터 류의 요소들이 담겨 있습니다.
- styles.xml : XML 형식으로 된 CSS라고 보시면 됩니다. 글꼴(font), 피치(pitch), 데코레이션(decoration), 스페이싱(spacing), 탭 스톱(tab stop) 등 문서 편집 시 이용할 수 있는 다양한 스타일이 정의되어 있습니다.


크리스마스카드를 만들어보자.
----------------------

연말이니, 크리스마스카드나 연하장등을 만들어볼 수 있을것 같습니다.
어릴 때 크리스마스 카드를 참 많이 썼습니다.
처음엔 공 들여서 이런저런 이야기를 쓰다가 써야할 친구들이 점차 늘어나면,
내용은 계속 똑같이 베껴 쓰면서 받는 친구의 이름만 바꿨던 기억이 납니다.
그럼 처음 한번만 예쁘게 카드를 꾸미고, 이름만 쓰면 크리스마스 카드가 나오게 해보면 어떨까요?
만들어 봅시다.

우선 `template.odt`를 만들어 봅시다. 여기서 만든다는 것은 '꾸미고 싶은 만큼 잔뜩 꾸미는 것' 입니다.
다음으로는 가변데이터가 될 부분을 표시합니다.
예를들어,크리스마스 카드의 경우 받는 사람의 이름이나, 날짜등은 계속 바뀔 것입니다.
네, 그것이 핵심이죠! 문서를 계속 우려서 자동생성하되, 필요한 부분의 데이터만
받아서 이용하는 것 말입니다.
그렇다면 가변데이터가 될 부분을 'xxxx'라고 표시해 봅니다.

 ![xxxx표시][basic]

이 정도면 벌써 반이상 진행되었습니다. 다음으로는 `unzip`유틸리티를 사용해 `template.odt`를 분해해봅시다.
우리에게 필요한 것은 위에서 설명했던 내용을 담는 파일인 `content.xml`과
ODF의 css인 `style.xml`입니다. 이 두파일만 남기고 모두 지워도 좋습니다.

이제 `content.xml`을 열어 `xxxx`를 찾아봅니다.
수 많은 문자열중 절대 겹치지 않을 것 같은 `xxxx`로 표시해두었기 때문에
찾기가 수월합니다. 그리고 `xxxx`를 찾아서 사용할 변수로 바꿔줍시다.
앗, 그런데 `content.xml`을 열어보면 보기 힘든 코드들이 마구 쏟아져서 어디서 수정을 해야할지 답답함을 느끼실 겁니다.
이럴 땐, `XML::Tidy`모듈을 설치하고 다음과 같은 명령어를 치면, 아름답게 정리된 코드를 볼 수 있습니다.

    #!bash
    $ xmltidy content.xml

다시 xxxx가 씌여있는 곳을 찾아봅니다.
 
![xxxx표시-xml][before-xxxx]

네, 있습니다. 그럼 이부분의 값만 바꿔주면, 이 안에 넣고 싶은 데로 넣을 수 있겠죠?
이 부분을 [% name %], [% date.y %]...등으로 바꿔줍니다.

 ![xxxx표시-xml-a][after-date]

거의 다왔습니다. 이제는 Perl이 나설 차례입니다.
우선 ODT를 사용할 핵심 모듈인 `OpenDocument::Template`을 cpan을 이용해 설치합니다.
그리고 다음과 같이 코드를 작성해 봅시다.

    #!perl
    use 5.010;
    use utf8;
    use strict;
    use warnings;
 
    use OpenDocument::Template;
 
    my $name  = "이민선";
    my %date  = ( 
            "y"=>"2011",
            "m"=>"12",
            "d"=>"8",
    );

    my $time=time;

    my $template_dir = 'templates';
    my $src          = 'template.odt';
    my $dest = sprintf "templates/result/%s-%s.odt", $time,$name;
 
    my %config_file;

    $config_file{templates}{'content.xml'} = {
        name    => $name,
        date      => \%date,
    };
 
    my $odt = OpenDocument::Template->new(
        config       => \%config_file,
        template_dir => $template_dir,
        src          => $src,
        dest         => $dest,
    );
    $odt->generate;

이것이 바로 ODT를 만들어주는 perl코드의 예 입니다.
각 코드가 하는 일은 다음과 같습니다.

- src : 원본 odt파일로, 템플릿 역할을 합니다.
- config_file : 변경될 내용들을 담고 있고, 템플릿 툴킷용 파일의 이름과 템플릿 처리시 사용할 변수값이 들어있습니다.
- template_dir : 템플릿 파일을 저장하는 디렉토리 입니다.
- dest : 결과입니다.

이렇게 완성입니다. 이제 실행만 하면 크리스마스카드가 ODT로 생성됩니다.

 ![크리스마스카드][xmas-card.png]

이 코드를 조금 더 발전시켜서,
표준입력으로 받는 이름을 명령행 인자로 받으면 훨씬 더 수훨하게 ODT를 생성할 수 있겠죠? :)


가변데이터를 웹에서 받는 다면?
---------

네, 그렇다면 이러한 것들을 카탈리스트 앱으로 만들면 web에서 훨씬 더 수월하게 접근할 수 있지 않을까요?
예를 들어, 자주 써야하는 보고서나 문서들의 서식을 처음 한번만 만들어 놓고,
변해야 하는 데이터들만 웹에서 받아 문서를 생성한다면 문서 생성이 정말 간편할 것입니다.
그래서 준비한 다양한 Form들 입니다.

## 카탈리스트 에선 어떤식으로 할까?

 ![카탈리스트로고][catalyst]

카탈리스트는 웹 어플리케이션 프레임워크입니다.
회사 업무로도 이용하고 있는데요, 이 기사에서는 카탈리스트의 자세한 부분은 다루지 않습니다.
작년 @Jeen님이 쓰신 Advent Calendar 기사나 블로그 링크를 참조하면,
다음 내용들도 쉽게 실습할 수 있을 것입니다.

- 나의 Catalyst 답사기 at 2010 Advent Calendar : http://advent.perl.kr/2010/2010-12-12.html
- [ Perl ] Catalyst 를 이용한 웹 서비스 개발 #1 : http://jeen.tistory.com/93

카탈리스트를 설치하고 나면 다음의 작업을 진행해 봅시다.
다음 작업들은 순서에 관계 없으며,
세 부분에서 모두 작업이 완성되야, form나는 서식 파일을 받아보실 수 있습니다.

### Controller에서

사용자가 웹에서 입력한 값을 이용해, 서식 파일을 만들고자 합니다.
아래 서브루틴에서는 `form_index.tt`파일에서 넘겨 준 변수를 가져와
`content.xml`에 넘겨주는 과정입니다.

    #!perl
    sub form_create_do :Chained('index') :PathPart('form_create_do') :Args(0) {
        my ($self, $c) = @_;
        
        my $subject         = $c->req->param('subject');
        my $short_comment   = $c->req->param('short_comment');
        my $detail_comment  = $c->req->param('detail_comment');
        my $picture         = $c->req->param('picture');
        my $phone           = $c->req->param('phone');
        my $name            = $c->req->param('name');
        
        
        my %formna_config;
        
        $formna_config{templates}{'content.xml'} = {
            subject        => $subject,
            short_comment  => $short_comment,
            detail_comment => $detail_comment,
            picture        => $picture,
            phone          => $phone,
            name           => $name,
        };
    
        my $tpl_dir = sprintf "%s/templates", $c->config->{odt}{root_notice};
        my $src = sprintf "%s/template.odt", $c->config->{odt}{root_notice};
        my $time = time;
        my $dst = sprintf "%s/result/%s.odt", $c->config->{odt}{root_notice}, $time;
        
        my $odt = OpenDocument::Template->new(
            config       => \%formna_config,
            template_dir => $tpl_dir,
        	  src          => $src,
        	  dest         => $dst,
        );
        $odt->generate;
        $c->log->debug("Generated $dst");

        $c->res->headers->content_type('application/msword');
        $c->res->headers->header("Content-Disposition" => 'attachment;filename="' . "$time.doc" . '";');
        my $fh = IO::File->new( $dst, 'r' );
        $c->res->body($fh);
        undef $fh;

가장아래 5줄은, 사용자가 입력을 마치고 문서를 생성할 때,
생성된 odt파일을 doc확장자로 다운받을 수 있게 하는 코드입니다.

### View단에서

값을 넘겨 줄 부분을 다음과 같이 form으로 사용자에게 입력받습니다.

    #!xml
    [% meta.title = '전단지 생성' -%]
    <form  action="[% c.uri_for('form_create_do') %]"  method="post" enctype="multipart/form-data">
      <div>
      <label>제목</label>
        <input type="text" name="subject" />
      </div>
    ...(생략)...

### content.xml에서

처음 크리스마스 카드를 만들 때 처럼 ODT를 생성한후 content.xml파일을 변경해봅니다.

    #!xml
    <text:p text:style-name="Standard">[% subject %]</text:p>
    <text:p text:style-name="Standard">[% short_comment %]</text:p>
    <text:p text:style-name="Standard">[% detail_comment %]</text:p>
    <text:p text:style-name="Standard">[% picture %]</text:p>
    <text:p text:style-name="Standard">[% phone %]</text:p>

## 결과 예제들

이제 위와 같은 작업들을 통해,
다음과 같이 자주 쓰지만, 만들기는 귀찮은  Form들을 만들어봤습니다.

 ![메인][formna]

- 이력서
- 문어발 전단지
- FTA 국회의원 상장 만들기

다음 링크에서 확인하실 수 있습니다.

http://formna.silex.kr

Tip , 하다보면 요령이 생깁니다.
---------------

xxxx를 넣고 xxxx를 찾아 변수를 바꾸는 작업들이
매번 하다보면 귀찮습니다.
저도 처음엔 xxxx를 찾아 변수로 바꿨는데,
애초에 template.odt를 만들당 시 변수를 받을 곳에
`[% .. %]`를 써서 넣는다면 더욱 간편하게 이용하실수 있습니다.

또 만들다 보니, odt파일에 글자가 `뷁뷁샭략`과 같이 들어갈 때도 있습니다.
이것은 인코딩 문제로 다음과 같이, 카탈리스트의 각종 설정파일에서 utf8을 설정해서
해결할 수 있습니다.

`TT.pm`에서는 다음과 같이 `ENCODING => \`utf8\``을 추가해줍니다.

    #!perl
    __PACKAGE__->config(
        TEMPLATE_EXTENSION => '.tt',
        render_die => 1,
        ENCODING => 'utf8',
    );

`FormNa/Web.pm`에서는 다음과 같이 `utf8`인코딩에 대한 내용을 설정합니다.

    #!perl
    use Catalyst qw/
        -Debug
        ConfigLoader
        Static::Simple
        Unicode::Encoding
    /;

마지막으로 config파일 에도 추가합니다.

    #!plain
    <View Default>
        ENCODING                utf8
    </View Default>


삶에서의 응용
-----------

이렇게 가변 데이터로 ODT를 만드는 것의 첫번째 장점은 **예쁜** 보고서를 만들 수 있다는 것입니다.
실제로 제가 회사에서 한 업무로는 한 대학병원 연구실의 연구별 예산을 데이터베이스에 넣어놓고,
필요할 때마다, ODT파일로 만든 다음 PDF로 변환하여 예산내역서를 뽑을 수 있게 하는 것입니다.
이런식으로 `content.xml`을 둘러보면 테이블이나 문단, 이미지등 다양한 요소들이 있습니다.
만들고 싶은 보고서 서식을 만들고,
여기에  foreach,if와 같은 조건문들을 이용해 적절히 요리하면
본인이, 또는 고객이 만족하는 예쁜 Form들을 만들수 있습니다.


마칩니다
----------

평소에 해왔던 작업이라 빠른 시간내에, 기사작성과 카탈리스트 앱을 작성할 수 있을 것
같았지만 오해였습니다.
글을 쓸 수 있게 도와주신 @keedi님, @y0ngbin님께 무한 감사드립니다.
또 막판에, 비루한 웹 UI에 희망을 불어넣어준 @am0c군에게도 고맙습니다.
http://formna.silex.kr 이 비록 예제이지만,
보시는 분들께,실생활에 도움이 되길 바래봅니다.



[basic]         : basic.png
[before-xxxx] : before-xxxx.png
[after-date]   : after-date.png
[xmas-card]  : xmas-card.png 
[catalyst]     : catalyst.png
[formna]      : formna.png
