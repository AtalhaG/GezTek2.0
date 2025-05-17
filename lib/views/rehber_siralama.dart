import 'package:flutter/material.dart';
import 'custom_bars.dart';

class RehberSiralamaCard extends StatelessWidget {
  final String rehberAdi;
  final String diller;
  final double puan;
  final String turListesi;
  final String profilResimYolu;
  final VoidCallback? onTap;

  const RehberSiralamaCard({
    super.key,
    required this.rehberAdi,
    required this.diller,
    required this.puan,
    required this.turListesi,
    required this.profilResimYolu,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol kısım: Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rehberAdi,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        diller,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            puan.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        turListesi,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Sağ kısım: Profil fotoğrafı
                SizedBox(width: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                  ),
                  elevation: 6,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(profilResimYolu),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RehberSiralamaSayfasi extends StatefulWidget {
  const RehberSiralamaSayfasi({super.key});

  @override
  State<RehberSiralamaSayfasi> createState() => _RehberSiralamaSayfasiState();
}

class _RehberSiralamaSayfasiState extends State<RehberSiralamaSayfasi> {
  String? seciliSehir;
  String? seciliTurTipi;
  String? seciliDil;
  double? seciliPuan;
  DateTime? baslangicTarihi;
  DateTime? bitisTarihi;

  final List<String> sehirler = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
    'Adana',
    'Trabzon',
    'Gaziantep',
    'Eskişehir',
    'Mersin',
  ];
  final List<String> turTipleri = [
    'Kültür',
    'Doğa',
    'Yemek',
    'Macera',
    'Deniz',
    'Tarih',
  ];
  final List<String> diller = [
    'Türkçe',
    'İngilizce',
    'Almanca',
    'Fransızca',
    'İspanyolca',
  ];
  final List<double> puanlar = [5.0, 4.5, 4.0, 3.5, 3.0];

  void _sehirFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String? secili = seciliSehir;
        return _FiltreListModal<String>(
          title: 'Şehir Seçiniz',
          items: sehirler,
          selected: secili,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliSehir = sonuc;
      });
    }
  }

  void _turTipiFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String? secili = seciliTurTipi;
        return _FiltreListModal<String>(
          title: 'Tur Tipi Seçiniz',
          items: turTipleri,
          selected: secili,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliTurTipi = sonuc;
      });
    }
  }

  void _dilFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        String? secili = seciliDil;
        return _FiltreListModal<String>(
          title: 'Dil Seçiniz',
          items: diller,
          selected: secili,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliDil = sonuc;
      });
    }
  }

  void _puanFiltreAc() async {
    final sonuc = await showModalBottomSheet<double>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        double? secili = seciliPuan;
        return _FiltreListModal<double>(
          title: 'Puan Seçiniz',
          items: puanlar,
          selected: secili,
          itemBuilder:
              (puan) => Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 4),
                  Text(puan.toString()),
                ],
              ),
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliPuan = sonuc;
      });
    }
  }

  void _tarihFiltreAc() async {
    DateTime? baslangic = baslangicTarihi;
    DateTime? bitis = bitisTarihi;
    final sonuc = await showModalBottomSheet<Map<String, DateTime>?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _TarihFiltreModal(
          baslangic: baslangic,
          bitis: bitis,
          onApply:
              (b, t) => Navigator.of(context).pop({'baslangic': b, 'bitis': t}),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        baslangicTarihi = sonuc['baslangic'];
        bitisTarihi = sonuc['bitis'];
      });
    }
  }

  void _filtreleriTemizle() {
    setState(() {
      seciliSehir = null;
      seciliTurTipi = null;
      seciliDil = null;
      seciliPuan = null;
      baslangicTarihi = null;
      bitisTarihi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F3),
      body: Column(
        children: [
          const CustomTopBar(),
          Expanded(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      _FiltreButton(
                        text:
                            seciliSehir != null
                                ? 'Şehir: $seciliSehir'
                                : 'Şehir',
                        onTap: _sehirFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            (baslangicTarihi != null && bitisTarihi != null)
                                ? 'Tarih: ${baslangicTarihi!.day}.${baslangicTarihi!.month}.${baslangicTarihi!.year} - ${bitisTarihi!.day}.${bitisTarihi!.month}.${bitisTarihi!.year}'
                                : 'Tarih',
                        onTap: _tarihFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliTurTipi != null
                                ? 'Tur Tipi: $seciliTurTipi'
                                : 'Tur Tipi',
                        onTap: _turTipiFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: seciliDil != null ? 'Dil: $seciliDil' : 'Dil',
                        onTap: _dilFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliPuan != null
                                ? 'Puan: ${seciliPuan!.toString()}'
                                : 'Puan',
                        onTap: _puanFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: 'Temizle',
                        color: Colors.red[700],
                        onTap: _filtreleriTemizle,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: ListView(
                    children: [
                      RehberSiralamaCard(
                        rehberAdi: 'Safir Soysal',
                        diller: 'Türkçe, İngilizce',
                        puan: 5.0,
                        turListesi: 'Bardakçı Turu, İzmir Turu',
                        profilResimYolu: 'assets/images/geztek.jpg',
                        onTap: () {},
                      ),
                      RehberSiralamaCard(
                        rehberAdi: 'Mehmet Yılmaz',
                        diller: 'Almanca, Türkçe',
                        puan: 4.7,
                        turListesi: 'Efes Turu, Kapadokya Turu',
                        profilResimYolu: 'assets/images/geztek.jpg',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 1),
    );
  }
}

class _FiltreButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const _FiltreButton({
    required this.text,
    required this.onTap,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF22543D),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _FiltreListModal<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selected;
  final Widget Function(T)? itemBuilder;
  final void Function(T) onSelected;
  const _FiltreListModal({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.itemBuilder,
    super.key,
  });

  @override
  State<_FiltreListModal<T>> createState() => _FiltreListModalState<T>();
}

class _FiltreListModalState<T> extends State<_FiltreListModal<T>> {
  T? secili;
  @override
  void initState() {
    super.initState();
    secili = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return RadioListTile<T>(
                    title:
                        widget.itemBuilder != null
                            ? widget.itemBuilder!(item)
                            : Text(item.toString()),
                    value: item,
                    groupValue: secili,
                    onChanged: (val) {
                      setState(() {
                        secili = val;
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(secili),
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarihFiltreModal extends StatefulWidget {
  final DateTime? baslangic;
  final DateTime? bitis;
  final void Function(DateTime?, DateTime?) onApply;
  const _TarihFiltreModal({
    required this.baslangic,
    required this.bitis,
    required this.onApply,
    super.key,
  });

  @override
  State<_TarihFiltreModal> createState() => _TarihFiltreModalState();
}

class _TarihFiltreModalState extends State<_TarihFiltreModal> {
  DateTime? baslangic;
  DateTime? bitis;

  @override
  void initState() {
    super.initState();
    baslangic = widget.baslangic;
    bitis = widget.bitis;
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (baslangic ?? now) : (bitis ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          baslangic = picked;
        } else {
          bitis = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tarih Aralığı Seçin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                baslangic != null
                    ? 'Başlangıç: ${baslangic!.day}.${baslangic!.month}.${baslangic!.year}'
                    : 'Başlangıç tarihi seçilmedi',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(isStart: true),
              child: const Text('Başlangıç Tarihi Seç'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                bitis != null
                    ? 'Bitiş: ${bitis!.day}.${bitis!.month}.${bitis!.year}'
                    : 'Bitiş tarihi seçilmedi',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(isStart: false),
              child: const Text('Bitiş Tarihi Seç'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () => widget.onApply(baslangic, bitis),
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
