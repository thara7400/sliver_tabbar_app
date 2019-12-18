import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliverTabApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SliverTabApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var _tabs = [
    'First',
    'Second',
    'Third'
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: DefaultTabController(
          // タブの数
          length: _tabs.length,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              // 外側のスクロールビューに表示されるSliver（AppBarとTabBar）
              return <Widget>[
                SliverOverlapAbsorber(
                  /**
                   * SliverOverlapAbsorberはSliverAppBarをオーバーラップし、下部のSliverOverlapInjectorにリダイレクトします。
                   * SliverOverlapInjectorがない時、内側のスクロールビューがスクロールされていないと判断された場合でもネストされた
                   * 内側のスクロールビューがSliverAppBarの下に配置される可能性があります。
                   * headerSliverBuilderが次のスライバーと重ならないウィジェットのみを構築する場合、これは必要ありません。
                   */
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  child: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      title: Text(widget.title),
                      floating: true,
                      pinned: true,
                      snap: false,
                      primary: true,
                      forceElevated: innerBoxIsScrolled,
                      bottom: TabBar(
                        // タブバーの各タブに配置するウィジェット
                        tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              // タブの下に置かれるTabViewの内容
              children: _tabs.map((String name) {
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Builder(
                    /**
                     * このBuilderはsliverOverlapAbsorberHandleForがNestedScrollViewを
                     * 認識できるようにNestedScrollViewの内側にあるBuildContextを提供するために必要です。
                     */
                    builder: (BuildContext context) {
                      return CustomScrollView(
                        /**
                         * NestedScrollViewがこの内部スクロールビューを制御できるように、「コントローラー」および「プライマリ」メンバーは未設定のままにしておく必要があります。
                         * 「controller」プロパティが設定されている場合、このスクロールビューはNestedScrollViewに関連付けられません。
                         * PageStorageKeyは、このScrollViewに一意である必要があります。 タブビューが画面上にないときに、リストがスクロール位置を記憶できるようにします。
                         */
                        key: PageStorageKey<String>(name),
                        slivers: <Widget>[
                          SliverOverlapInjector(
                            // これは、上記のSliverOverlapAbsorberの裏側です。
                            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(8.0),
                            /**
                             * この例では、内側のスクロールビューに固定高さのリストアイテムがあるため、SliverFixedExtentListを使用しています。
                             * ただし、ここで任意のスライバウィジェットを使用できます。SliverListまたはSliverGrid。
                             */
                            sliver: SliverFixedExtentList(
                              /**
                               * この例の項目は、高さ48ピクセルに固定されています。 これは、ListTileウィジェットのマテリアルデザイン仕様と一致します。
                               */
                              itemExtent: 60.0,
                              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                                  /**
                                   * このビルダーは、各子に対して呼び出されます。
                                   * この例では、各リスト項目に番号を付けています。
                                   */
                                return Container(
                                  color: Color(
                                      (Random().nextDouble() * 0xFFFFFF).toInt() << 0
                                  ).withOpacity(1.0),
                                  child: Center(
                                    child: Text(index.toString()),
                                  ),
                                );
                              },
                                // 各タブのリストビューが持つ子の数
                                childCount: 50),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
