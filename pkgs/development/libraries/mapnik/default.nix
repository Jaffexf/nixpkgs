{ stdenv, fetchzip, fetchpatch
, boost, cairo, freetype, gdal, harfbuzz, icu, libjpeg, libpng, libtiff
, libwebp, libxml2, proj, python2, scons, sqlite, zlib

# supply a postgresql package to enable the PostGIS input plugin
, postgresql ? null
}:

stdenv.mkDerivation rec {
  name = "mapnik-${version}";
  version = "3.0.13";

  src = fetchzip {
    # this one contains all git submodules and is cheaper than fetchgit
    url = "https://github.com/mapnik/mapnik/releases/download/v${version}/mapnik-v${version}.tar.bz2";
    sha256 = "189wsd6l6awblkiha666l1sdyp7ifmnfsa87y0j37rvym6w4r065";
  };

  patches = [(fetchpatch {
    name = "icu-59.diff";
    url = https://github.com/mapnik/mapnik/commit/9e58c890430d.diff;
    sha256 = "0h546qq8g19gw9s4979hla9vkq5kcwh3q45ryajyjhmlr2z9fi6p";
  })];

  # a distinct dev output makes python-mapnik fail
  outputs = [ "out" ];

  nativeBuildInputs = [ python2 scons ];

  buildInputs =
    [ boost cairo freetype gdal harfbuzz icu libjpeg libpng libtiff
      libwebp libxml2 proj python2 sqlite zlib

      # optional inputs
      postgresql
    ];

  configurePhase = ''
    scons configure PREFIX="$out" BOOST_INCLUDES="${boost.dev}/include" \
                                  BOOST_LIBS="${boost.out}/lib" \
                                  CAIRO_INCLUDES="${cairo.dev}/include" \
                                  CAIRO_LIBS="${cairo.out}/lib" \
                                  FREETYPE_INCLUDES="${freetype.dev}/include" \
                                  FREETYPE_LIBS="${freetype.out}/lib" \
                                  GDAL_CONFIG="${gdal}/bin/gdal-config" \
                                  HB_INCLUDES="${harfbuzz.dev}/include" \
                                  HB_LIBS="${harfbuzz.out}/lib" \
                                  ICU_INCLUDES="${icu.dev}/include" \
                                  ICU_LIBS="${icu.out}/lib" \
                                  JPEG_INCLUDES="${libjpeg.dev}/include" \
                                  JPEG_LIBS="${libjpeg.out}/lib" \
                                  PNG_INCLUDES="${libpng.dev}/include" \
                                  PNG_LIBS="${libpng.out}/lib" \
                                  PROJ_INCLUDES="${proj}/include" \
                                  PROJ_LIBS="${proj}/lib" \
                                  SQLITE_INCLUDES="${sqlite.dev}/include" \
                                  SQLITE_LIBS="${sqlite.out}/lib" \
                                  TIFF_INCLUDES="${libtiff.dev}/include" \
                                  TIFF_LIBS="${libtiff.out}/lib" \
                                  WEBP_INCLUDES="${libwebp}/include" \
                                  WEBP_LIBS="${libwebp}/lib" \
                                  XML2_INCLUDES="${libxml2.dev}/include" \
                                  XML2_LIBS="${libxml2.out}/lib"
  '';

  buildPhase = false;

  installPhase = ''
    mkdir -p "$out"
    scons install
  '';

  meta = with stdenv.lib; {
    description = "An open source toolkit for developing mapping applications";
    homepage = http://mapnik.org;
    maintainers = with maintainers; [ hrdinka ];
    license = licenses.lgpl21;
    platforms = platforms.all;
  };
}
