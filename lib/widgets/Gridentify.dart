import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:gridentify/storage/Highscore.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

class Gridentify extends StatefulWidget {

  final HighScoreStorage storage;


  Gridentify(this.storage);

  @override
  _GridentifyState createState() {
    return new _GridentifyState();
  }
}

class _GridentifyState extends State<Gridentify> {
  final key = GlobalKey();
  final Set<int> selectedIndexes = Set<int>();
  final Set<_SquareBox> _trackTaped = Set<_SquareBox>();
  final List<int> grid = List<int>();
  final List<Color> colors = [
    Color(0xffa9ffc3),//selected
    Color(0xffa9e3ff),//1
    Color(0xffa9bcff),//2
    Color(0xffa9acff),//3
    Color(0xffdaa9ff),//4+
  ];

  int highscore = 0;
  int score = 0;
  bool isGameOver = false;

  @override initState(){
    super.initState();
    widget.storage.highscore.then((int val){
      setState((){
        highscore = val;
      });
    });
  }

  _detectTapedItem(PointerEvent event) {
    final RenderBox box = key.currentContext.findRenderObject();
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is _SquareBox) {
          if(!_trackTaped.contains(target) && (_trackTaped.length==0 || (_trackTaped.length>=1 && _getNeighborsOf(target.index).contains(_trackTaped.last.index)))){
            _select(target);
          }else{
            _unselect(target);
          }
        }
      }
    }
  }

  List<int> _getNeighborsOf(int idx){
    List<int> neighbors = List<int>();

    if((idx%5) != 0){
      neighbors.add(idx -1);
    }
    if(((idx+1)%5) != 0){
      neighbors.add(idx + 1);
    }
    if(idx>=5){
      neighbors.add(idx - 5);
    }
    if(idx<20){
      neighbors.add(idx + 5);
    }
    return neighbors;
  }

  _unselect(_SquareBox target){
    setState(() {
      Set<int> indexes = Set<int>();
      Set<_SquareBox> boxes = Set<_SquareBox>();
      List<_SquareBox> list = _trackTaped.toList();
      for(int i = 0; i<list.length;i++){

        indexes.add(list[i].index);
        boxes.add(list[i]);

        if(list[i] == target){
          break;
        }
      }
      _trackTaped..clear()..addAll(boxes);
      selectedIndexes..clear()..addAll(indexes);
    });
  }

  _select(_SquareBox target) {
    setState(() {
      _trackTaped.add(target);
      selectedIndexes.add(target.index);
    });
  }

  _restart(){
    setState((){
      score = 0;
      isGameOver = false;
      Random _rand = Random();
      grid.clear();
      for(int i = 0; i<25; i++){
        grid.add(1+_rand.nextInt(3));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Random _rand = Random();
    if(grid.length == 0){
      for(int i = 0; i<25; i++){
        grid.add(1+_rand.nextInt(3));
      }
    }
    return Scaffold(
      body: Listener(
        onPointerDown: _detectTapedItem,
        onPointerMove: _detectTapedItem,
        onPointerUp: _clearSelection,
        child: Container(
          padding: EdgeInsets.only(top:40.0),
          color: Color(0xffeeeeee),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text("Gridentifier",
                    style:TextStyle(
                        color:Color(0xff444444),
                        fontSize: 25.0,
                    )
                ),
              ),
              Expanded(
                child: GridView.builder(
                  key: key,
                  itemCount: 25,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemBuilder: (BuildContext context, index) {
                    Color c;
                    if(grid[index]>colors.length-1){
                      c = colors.last;
                    }else{
                      c = colors[grid[index]];
                    }

                    if(this.selectedIndexes.contains(index)){
                      c = colors[0];
                    }

                    return Square(index:index,
                      child: Container(
                        color: c,
                        child: Center(
                          child: Text(
                              grid[index].toString(),
                              style: TextStyle(fontSize: 20.0)
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 70.0),
                child: Text(score.toString(),
                    style:TextStyle(
                        color:Color(0xff444444),
                        fontSize: 60.0
                    )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Highscore : $highscore'),
                  Text(isGameOver?"Game Over":"Still running"),
                  IconButton(
                    icon: Icon(Icons.refresh, size:40.0),
                    onPressed: _restart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearSelection(PointerUpEvent event) {
    if(_trackTaped.length == 0){
      return;
    }
    bool same = true;
    int firstVal = grid[_trackTaped.elementAt(0).index];
    for(int i = 1; i<_trackTaped.length; i++){
      int currentVal = grid[_trackTaped.elementAt(i).index];
      same = same && firstVal == currentVal;
    }
    if(same){
      Random _rand = Random();
      for(int i = 0; i<_trackTaped.length-1; i++){
        grid[_trackTaped.elementAt(i).index] = 1+_rand.nextInt(3);
      }
      int idx = _trackTaped.elementAt(_trackTaped.length-1).index;
      grid[idx] = (_trackTaped.length * grid[idx]);
      if(_trackTaped.length > 1){
        score += grid[idx];
      }
    }

    isGameOver = true;
    for(int i = 0; i<grid.length; i++){
      List<int> l = _getNeighborsOf(i);
      l.forEach((idx){
        if(grid[idx] == grid[i]){
          isGameOver = false;
        }
      });
      if(!isGameOver){
        break;
      }
    }

    if(isGameOver){
      if(score > highscore){
        highscore = score;
        widget.storage.setHighscore(score);
      }
    }

    _trackTaped.clear();
    setState(() {
      selectedIndexes.clear();
    });
  }
}


class Square extends SingleChildRenderObjectWidget {
  final int index;

  Square({Widget child, this.index, Key key}) : super(child: child, key: key);

  @override
  _SquareBox createRenderObject(BuildContext context) {
    return _SquareBox()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, _SquareBox renderObject) {
    renderObject..index = index;
  }

}

class _SquareBox extends RenderProxyBox {
  int index;
}
