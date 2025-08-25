# MySQL Secret Kullanım Kılavuzu

Bu dizin MySQL veritabanı bilgilerini güvenli bir şekilde saklamak için Kubernetes Secret'larını içerir.

## Dosyalar

- `mysql-secret.yaml`: MySQL veritabanı bilgilerini içeren Secret manifesti
- `mysql-secret-usage-example.yaml`: Secret'ı nasıl kullanacağını gösteren örnek Deployment ve Service
- `README.md`: Bu dosya

## Secret'ı Güncelleme

Mevcut Secret'taki değerleri güncellemek için:

### 1. Yeni değerleri base64 ile encode edin:

```bash
# Root şifresi
echo -n "yeni-root-sifresi" | base64

# Kullanıcı adı
echo -n "yeni-kullanici" | base64

# Kullanıcı şifresi
echo -n "yeni-sifre" | base64

# Veritabanı adı
echo -n "yeni-veritabani" | base64

# Host adresi
echo -n "mysql-service" | base64

# Port numarası
echo -n "3306" | base64
```

### 2. Secret manifestini güncelleyin:

`mysql-secret.yaml` dosyasındaki `data` bölümündeki değerleri yukarıda oluşturduğunuz base64 encoded değerlerle değiştirin.

### 3. Secret'ı uygulayın:

```bash
kubectl apply -f mysql-secret.yaml
```

## Secret'ı Kullanma

### Environment Variables olarak:

```yaml
env:
  - name: MYSQL_ROOT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mysql-secret
        key: mysql-root-password
  - name: MYSQL_USER
    valueFrom:
      secretKeyRef:
        name: mysql-secret
        key: mysql-username
```

### Volume olarak:

```yaml
volumes:
  - name: mysql-secret-volume
    secret:
      secretName: mysql-secret
      items:
        - key: mysql-root-password
          path: root-password
        - key: mysql-username
          path: username
```

## Güvenlik Notları

1. **Production ortamında**: Gerçek şifreler kullanın ve güvenli bir şekilde saklayın
2. **RBAC**: Secret'lara erişimi kısıtlayın
3. **Encryption**: Kubernetes Secret encryption'ını etkinleştirin
4. **Rotation**: Şifreleri düzenli olarak değiştirin

## Mevcut Secret'ı Görüntüleme

```bash
# Secret'ı görüntüle
kubectl get secret mysql-secret

# Secret detaylarını görüntüle
kubectl describe secret mysql-secret

# Secret'ı YAML formatında görüntüle
kubectl get secret mysql-secret -o yaml
```

## Secret'ı Silme

```bash
kubectl delete secret mysql-secret
```

## Örnek Kullanım

Örnek Deployment ve Service'i uygulamak için:

```bash
kubectl apply -f mysql-secret-usage-example.yaml
```
