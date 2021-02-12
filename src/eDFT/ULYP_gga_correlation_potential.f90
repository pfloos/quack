subroutine ULYP_gga_correlation_potential(nGrid,weight,nBas,AO,dAO,rho,drho,Fc)

! Compute LYP correlation potential

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  integer,intent(in)            :: nBas
  double precision,intent(in)   :: AO(nBas,nGrid)
  double precision,intent(in)   :: dAO(ncart,nBas,nGrid)
  double precision,intent(in)   :: rho(nGrid,nspin)
  double precision,intent(in)   :: drho(ncart,nGrid,nspin)

! Local variables

  integer                       :: mu,nu,iG
  double precision              :: vAO,gaAO,gbAO
  double precision              :: ra,rb,r
  double precision              :: ga,gab,gb,g
  double precision              :: dfdra,dfdrb
  double precision              :: fdga,dfdgb
  double precision              :: doda,dodb,ddda,dddb

  double precision              :: a,b,c,d
  double precision              :: Cf,omega,delta

! Output variables

  double precision,intent(out)  :: Fc(nBas,nBas,nspin)

! Prameter of the functional

  a = 0.04918d0
  b = 0.132d0
  c = 0.2533d0
  d = 0.349d0

  Cf = 3d0/10d0*(3d0*pi**2)**(2d0/3d0)

! Compute matrix elements in the AO basis

  Fc(:,:,:) = 0d0

  do mu=1,nBas
    do nu=1,nBas
      do iG=1,nGrid

        ra = max(0d0,rho(iG,1))
        rb = max(0d0,rho(iG,2))
        r  = ra + rb
 
        if(r > threshold) then

          ga  = drho(1,iG,1)**2 + drho(2,iG,1)**2 + drho(3,iG,1)**2
          gb  = drho(1,iG,2)**2 + drho(2,iG,2)**2 + drho(3,iG,2)**2
          gab = drho(1,iG,1)*drho(1,iG,2) + drho(2,iG,1)*drho(2,iG,2) + drho(3,iG,1)*drho(3,iG,2)
          g   = ga + gab + gb

          omega = exp(-c*r**(-1d0/3d0))/(1d0 + d*r**(-1d0/3d0))*r**(-11d0/3d0)
          delta = c*r**(-1d0/3d0) + d*r**(-1d0/3d0)/(1d0 + d*r**(-1d0/3d0))

          vAO = weight(iG)*AO(mu,iG)*AO(nu,iG)

          doda = (d/(3d0*r**(4d0/3d0)*(1d0 + d*r**(-1d0/3d0)) + c/(3d0*r**(4d0/3d0)) - 11d0/(3d0*r))*omega
          dodb = doda
         
          ddda = - c/3d0*r**(-4d0/3d0) + d**2/(3d0*(1d0 + d*r**(-1d0/3d0))**2)*r**(-5d0/3d0) *
               - d/(3d0*(1d0 + d*r**(-1d0/3d0))*r**(-4d0/3d0)
          dddb = ddda

          Fc(mu,nu,1) = Fc(mu,nu,1) + vAO*dfdra

          Fc(mu,nu,2) = Fc(mu,nu,2) + vAO*dfdrb
          
          gaAO = drho(1,iG,1)*(dAO(1,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(1,nu,iG)) & 
               + drho(2,iG,1)*(dAO(2,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(2,nu,iG)) & 
               + drho(3,iG,1)*(dAO(3,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(3,nu,iG))
          gaAO = weight(iG)*gaAO

          gbAO = drho(1,iG,2)*(dAO(1,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(1,nu,iG)) & 
               + drho(2,iG,2)*(dAO(2,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(2,nu,iG)) & 
               + drho(3,iG,2)*(dAO(3,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(3,nu,iG))
          gbAO = weight(iG)*gbAO


          dfdga = -a*b*omega*(-rb**2 + 2d0/3d0*r**2 + ra*rb*( - 5d0/2d0 - (delta-11d0)/9d0*ra/r + delta/18d0))
          dfdgb = -a*b*omega*(-ra**2 + 2d0/3d0*r**2 + ra*rb*( - 5d0/2d0 - (delta-11d0)/9d0*rb/r + delta/18d0))
          
          Fc(mu,nu,1) = Fc(mu,nu,1) + 2d0*gaAO*dfdga
          Fc(mu,nu,2) = Fc(mu,nu,2) + 2d0*gbAO*dfdgb

        end if

      end do
    end do
  end do

end subroutine ULYP_gga_correlation_potential