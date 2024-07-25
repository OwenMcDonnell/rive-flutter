import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';

import 'src/utils.dart';

const assetName = 'CleanShot 2023-06-08 at 08.51.19@2x.png';

void main() {
  group("Test asset referencer behaviour.", () {
    test('Load a rive file, gets you one referencer.', () async {
      final riveBytes = loadFile('assets/sample_image.riv');
      final riveFile = RiveFile.import(
        riveBytes,
      );

      expect(riveFile.artboards.length, 1);
      final image = riveFile.artboards.first.component<Image>(assetName);

      final asset = image!.asset;

      expect(asset!.fileAssetReferencers.length, 1);
    });

    test('Make some artboard instances gets additional referencers.', () async {
      final riveBytes = loadFile('assets/sample_image.riv');
      final riveFile = RiveFile.import(
        riveBytes,
      );

      // each artboard adds file asset referencer.
      riveFile.artboards.first.instance();
      riveFile.artboards.first.instance();

      final image = riveFile.artboards.first.component<Image>(assetName);
      final asset = image!.asset!;
      expect(asset.fileAssetReferencers.length, 3);
    });

    test(
      'If we let instance get garbage collected they will get cleaned up.',
      () async {
        final riveBytes = loadFile('assets/sample_image.riv');
        final riveFile = RiveFile.import(
          riveBytes,
        );

        // each artboard adds file asset referencer.
        var count = 19;
        while (count-- > 0) {
          riveFile.artboards.first.instance();
        }

        final image = riveFile.artboards.first.component<Image>(assetName);
        final asset = image!.asset!;
        expect(asset.fileAssetReferencers.length, 20);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // ok, kinda lame, but the above allows garbage collection to kick in
        // which will remove referencers, its not really deterministic though

        expect(
          asset.fileAssetReferencers.length < 5,
          true,
          reason: "Expected ${asset.fileAssetReferencers.length} < 5",
        );
      },
      // skipping because it does not work, you can see things get
      // finalized but this does not consistently happen in tests.
      skip: true,
    );
  });
}
